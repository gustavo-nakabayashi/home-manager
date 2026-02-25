import { execSync, spawnSync } from "child_process";
import {
  existsSync,
  readFileSync,
  readdirSync,
  writeFileSync,
  mkdirSync,
  appendFileSync,
  unlinkSync,
  symlinkSync,
} from "fs";
import { basename, dirname, join, resolve } from "path";
import { homedir } from "os";

const GW_CONFIG = join(homedir(), ".config", "gw");
const SEARCH_PATHS_FILE = join(GW_CONFIG, "search-paths");
const PINS_FILE = join(GW_CONFIG, "pins");

const DEFAULT_SEARCH_PATHS = [
  "~/",
  "~/Programs/video-peel",
  "~/.config",
  "~/Programs",
  "~/Programs/bridge",
  "~/Programs/bridge/bridge-app-ui",
  "~/homelab",
  "~/Exercism/",
  "~/csprimer",
];

// --- Helpers ---

function die(msg: string): never {
  console.error(`Error: ${msg}`);
  process.exit(1);
}

function info(msg: string) {
  console.log(msg);
}

function git(args: string, cwd?: string): string {
  try {
    return execSync(`git ${args}`, {
      cwd,
      encoding: "utf-8",
      stdio: ["pipe", "pipe", "pipe"],
    }).trim();
  } catch (e: any) {
    throw new Error(e.stderr?.trim() || e.message);
  }
}

function gitOk(args: string, cwd?: string): boolean {
  try {
    git(args, cwd);
    return true;
  } catch {
    return false;
  }
}

function ensureConfigDir() {
  if (!existsSync(GW_CONFIG)) {
    mkdirSync(GW_CONFIG, { recursive: true });
  }
}

function seedSearchPaths() {
  ensureConfigDir();
  if (!existsSync(SEARCH_PATHS_FILE)) {
    writeFileSync(
      SEARCH_PATHS_FILE,
      "# gw search paths (one per line, ~ allowed, # comments)\n" +
        DEFAULT_SEARCH_PATHS.join("\n") +
        "\n"
    );
    info(`Created ${SEARCH_PATHS_FILE} with default paths`);
  }
}

function migratePins() {
  ensureConfigDir();
  const oldPinsFile = join(
    homedir(),
    ".config",
    "home-manager",
    "home",
    "tmux-worktree-pins"
  );
  if (!existsSync(PINS_FILE) && existsSync(oldPinsFile)) {
    const content = readFileSync(oldPinsFile, "utf-8");
    // Copy non-comment, non-empty lines
    const lines = content
      .split("\n")
      .filter((l) => l.trim() && !l.trim().startsWith("#"));
    writeFileSync(
      PINS_FILE,
      "# gw worktree pins (format: repo-name:/path)\n" +
        lines.join("\n") +
        (lines.length ? "\n" : "")
    );
    info(`Migrated pins from ${oldPinsFile} to ${PINS_FILE}`);
  }
}

function ensureConfig() {
  seedSearchPaths();
  migratePins();
}

function expandTilde(p: string): string {
  return p.startsWith("~/") ? join(homedir(), p.slice(2)) : p;
}

function readLines(file: string): string[] {
  if (!existsSync(file)) return [];
  return readFileSync(file, "utf-8")
    .split("\n")
    .map((l) => l.trim())
    .filter((l) => l && !l.startsWith("#"));
}

interface BareRepoInfo {
  bareDir: string;
  workDir: string;
  repoName: string;
}

function resolveBareRepo(cwd?: string): BareRepoInfo {
  const dir = cwd || process.cwd();

  const isBare = git("rev-parse --is-bare-repository", dir) === "true";
  if (isBare) {
    return {
      bareDir: dir,
      workDir: dirname(dir),
      repoName: basename(dir, ".git"),
    };
  }

  const gitDir = git("rev-parse --git-dir", dir);
  const gitCommonDir = git("rev-parse --git-common-dir", dir);

  if (gitCommonDir !== gitDir) {
    // Inside a worktree
    const bareDir = resolve(dir, gitCommonDir);
    return {
      bareDir,
      workDir: dirname(bareDir),
      repoName: basename(bareDir, ".git"),
    };
  }

  // Regular repo (not bare, not worktree)
  const topLevel = git("rev-parse --show-toplevel", dir);
  return {
    bareDir: "",
    workDir: topLevel,
    repoName: basename(topLevel),
  };
}

function smartFolderName(branchName: string, repoName: string): string {
  // feature/CORE-3670-Allow-form.io-choices-widget → repo-3670-last-three-words
  const match = branchName.match(/^[^/]+\/[^-]+-(\d+)/);
  if (match) {
    const taskNumber = match[1];
    const description = branchName.replace(/^[^/]+\/[^-]+-\d+-?/, "");
    const words = description.split("-").filter(Boolean);

    let lastWords = "";
    if (words.length >= 3) {
      lastWords = words.slice(-3).join("-");
    } else if (words.length > 0) {
      lastWords = words.join("-");
    }

    return lastWords
      ? `${repoName}-${taskNumber}-${lastWords}`.toLowerCase()
      : `${repoName}-${taskNumber}`.toLowerCase();
  }

  // Fallback: replace slashes with dashes, truncate
  const clean = branchName.replace(/\//g, "-").slice(0, 30);
  return `${repoName}-${clean}`.toLowerCase();
}

// --- Subcommands ---

function cmdInit(args: string[]) {
  if (args.length < 1) die("Usage: gw init <git-url> [target-dir]");

  const url = args[0];
  // Extract repo name from URL
  const repoName = basename(url, ".git").replace(/\.git$/, "");
  const targetDir = resolve(args[1] || repoName);

  if (existsSync(targetDir)) {
    die(`Target directory already exists: ${targetDir}`);
  }

  info(`Cloning ${url} into ${targetDir}...`);
  mkdirSync(targetDir, { recursive: true });

  const bareDir = join(targetDir, `${repoName}.git`);
  execSync(`git clone --bare ${url} ${bareDir}`, { stdio: "inherit" });

  // Fix refspec so origin/* refs work
  info("Fixing fetch refspec...");
  git(
    "config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'",
    bareDir
  );

  info("Fetching remote refs...");
  execSync("git fetch origin", { cwd: bareDir, stdio: "inherit" });

  // Detect default branch
  let defaultBranch = "main";
  try {
    const ref = git("symbolic-ref refs/remotes/origin/HEAD", bareDir);
    defaultBranch = ref.replace("refs/remotes/origin/", "");
  } catch {
    if (gitOk("show-ref --verify refs/remotes/origin/main", bareDir)) {
      defaultBranch = "main";
    } else if (
      gitOk("show-ref --verify refs/remotes/origin/master", bareDir)
    ) {
      defaultBranch = "master";
    }
  }

  info(`Creating worktree for default branch: ${defaultBranch}`);
  const mainWorktree = join(targetDir, "main");
  execSync(
    `git worktree add ${mainWorktree} ${defaultBranch}`,
    { cwd: bareDir, stdio: "inherit" }
  );

  // Auto-register
  cmdRegister([targetDir]);

  info("");
  info(`Initialized bare repo at ${bareDir}`);
  info(`Main worktree at ${mainWorktree}`);
  info(`Registered ${targetDir} in search paths`);
}

function cmdAdd(args: string[]) {
  if (args.length < 1) die("Usage: gw add <branch-name>");

  const branchName = args[0];
  const { bareDir, workDir, repoName } = resolveBareRepo();

  if (!bareDir) {
    die("Not inside a bare repo or worktree. Use 'gw init' to set one up.");
  }

  const folderName = smartFolderName(branchName, repoName);
  const targetPath = join(workDir, folderName);

  info("Fetching latest changes...");
  execSync("git fetch origin", { cwd: bareDir, stdio: "inherit" });

  info(`Creating worktree for branch: ${branchName}`);
  info(`Target folder: ${targetPath}`);

  const branchExists = gitOk(
    `show-ref --verify refs/remotes/origin/${branchName}`,
    bareDir
  );

  if (branchExists) {
    info("Branch exists remotely, checking it out...");
    execSync(`git worktree add ${targetPath} ${branchName}`, {
      cwd: bareDir,
      stdio: "inherit",
    });
  } else {
    info("Creating new branch based on origin/main...");
    execSync(
      `git worktree add -b ${branchName} ${targetPath} origin/main`,
      { cwd: bareDir, stdio: "inherit" }
    );
    // Unset tracking so it doesn't track origin/main
    try {
      git(`config --unset branch.${branchName}.remote`, bareDir);
    } catch {}
    try {
      git(`config --unset branch.${branchName}.merge`, bareDir);
    } catch {}
    info(`Remember to push with: git push -u origin ${branchName}`);
  }

  info("Worktree created successfully!");
  info(`Path: ${targetPath}`);
  info(`Branch: ${branchName}`);

  // Symlink files from main worktree
  const basePath = join(workDir, "main");
  if (existsSync(basePath)) {
    const filesToLink = [".env", ".mcp.json", ".envrc", ".claude/settings.local.json"];
    for (const file of filesToLink) {
      const src = join(basePath, file);
      const dst = join(targetPath, file);
      if (existsSync(src)) {
        const parentDir = dirname(dst);
        if (!existsSync(parentDir)) mkdirSync(parentDir, { recursive: true });
        try {
          unlinkSync(dst);
        } catch {}
        symlinkSync(src, dst);
        info(`Linked ${file}`);
      }
    }
  }

  info("");
  info("Starting tmux session...");
  spawnSync("tmux-sessionizer", [targetPath], { stdio: "inherit" });
}

function cmdList() {
  let bareDir: string;
  let workDir: string;
  try {
    const info = resolveBareRepo();
    bareDir = info.bareDir;
    workDir = info.workDir;
  } catch {
    die("Not inside a git repository");
  }

  if (!bareDir) {
    die("Not inside a bare repo or worktree.");
  }

  const output = git("worktree list", bareDir);

  // Read pins to mark pinned worktree
  const pins = readLines(PINS_FILE);
  const pinMap = new Map<string, string>();
  for (const line of pins) {
    const idx = line.indexOf(":");
    if (idx > 0) {
      pinMap.set(line.slice(0, idx), line.slice(idx + 1));
    }
  }

  const pinnedPaths = new Set(pinMap.values());

  for (const line of output.split("\n")) {
    const path = line.split(/\s+/)[0];
    const marker = pinnedPaths.has(path) ? " (pinned)" : "";
    console.log(`${line}${marker}`);
  }
}

function cmdRemove(args: string[]) {
  if (args.length < 1) die("Usage: gw remove <name> [--force]");

  const name = args[0];
  const force = args.includes("--force");

  let bareDir: string;
  let workDir: string;
  try {
    const info = resolveBareRepo();
    bareDir = info.bareDir;
    workDir = info.workDir;
  } catch {
    die("Not inside a git repository");
  }

  if (!bareDir) {
    die("Not inside a bare repo or worktree.");
  }

  const targetPath = join(workDir, name);

  if (!existsSync(targetPath)) {
    die(`Worktree path does not exist: ${targetPath}`);
  }

  const forceFlag = force ? " --force" : "";
  info(`Removing worktree: ${targetPath}`);

  try {
    execSync(`git worktree remove${forceFlag} ${targetPath}`, {
      cwd: bareDir,
      stdio: "inherit",
    });
    info(`Removed worktree: ${name}`);
  } catch {
    die(
      `Failed to remove worktree. Use --force to force removal.`
    );
  }
}

function cmdPin() {
  let topLevel: string;
  try {
    topLevel = git("rev-parse --show-toplevel");
  } catch {
    die("Not inside a git repository");
  }

  const repoName = basename(topLevel);

  // Derive base repo name by stripping worktree suffixes
  const baseRepoName = repoName
    .replace(/-\d+-.*$/, "")
    .replace(/-(main|current|dev|feature.*|fix.*|hotfix.*)$/, "");

  ensureConfigDir();

  // Read existing pins, remove old pin for this repo
  const existingLines = existsSync(PINS_FILE)
    ? readFileSync(PINS_FILE, "utf-8").split("\n")
    : ["# gw worktree pins (format: repo-name:/path)"];

  const filtered = existingLines.filter(
    (l) => !l.startsWith(`${baseRepoName}:`)
  );
  filtered.push(`${baseRepoName}:${topLevel}`);
  writeFileSync(PINS_FILE, filtered.join("\n") + "\n");

  // If running inside tmux, display a message
  try {
    execSync(
      `tmux display-message "Pinned ${baseRepoName} to ${topLevel}"`,
      { stdio: "pipe" }
    );
  } catch {
    info(`Pinned ${baseRepoName} to ${topLevel}`);
  }
}

function cmdRegister(args: string[]) {
  const pathArg = args[0] || process.cwd();
  const resolvedPath = resolve(expandTilde(pathArg));

  if (!existsSync(resolvedPath)) {
    die(`Path does not exist: ${resolvedPath}`);
  }

  ensureConfig();

  // Check if already registered
  const existing = readLines(SEARCH_PATHS_FILE);
  const normalizedExisting = existing.map((p) => resolve(expandTilde(p)));

  if (normalizedExisting.includes(resolvedPath)) {
    info(`Already registered: ${resolvedPath}`);
    return;
  }

  appendFileSync(SEARCH_PATHS_FILE, resolvedPath + "\n");
  info(`Registered: ${resolvedPath}`);
}

function cmdUnregister(args: string[]) {
  const pathArg = args[0] || process.cwd();
  const resolvedPath = resolve(expandTilde(pathArg));

  ensureConfig();

  if (!existsSync(SEARCH_PATHS_FILE)) {
    die("No search paths configured");
  }

  const content = readFileSync(SEARCH_PATHS_FILE, "utf-8");
  const lines = content.split("\n");
  const filtered = lines.filter((l) => {
    const trimmed = l.trim();
    if (!trimmed || trimmed.startsWith("#")) return true;
    return resolve(expandTilde(trimmed)) !== resolvedPath;
  });

  if (filtered.length === lines.length) {
    die(`Path not found in search paths: ${resolvedPath}`);
  }

  writeFileSync(SEARCH_PATHS_FILE, filtered.join("\n"));
  info(`Unregistered: ${resolvedPath}`);
}

function cmdPaths() {
  ensureConfig();

  const paths = readLines(SEARCH_PATHS_FILE);
  if (paths.length === 0) {
    info("No search paths configured. Use 'gw register <path>' to add paths.");
    return;
  }

  for (const p of paths) {
    const resolved = resolve(expandTilde(p));
    const exists = existsSync(resolved);
    console.log(`${exists ? " " : "!"} ${p}${p !== resolved ? ` -> ${resolved}` : ""}`);
  }
}

interface WorktreeEntry {
  path: string;
  branch: string;
}

function parseWorktreeList(bareDir: string): WorktreeEntry[] {
  const output = git("worktree list --porcelain", bareDir);
  const entries: WorktreeEntry[] = [];
  let currentPath = "";

  for (const line of output.split("\n")) {
    if (line.startsWith("worktree ")) {
      currentPath = line.slice("worktree ".length);
    } else if (line.startsWith("branch ")) {
      const branch = line.slice("branch refs/heads/".length);
      entries.push({ path: currentPath, branch });
    }
  }

  return entries;
}

function findBareRepos(): string[] {
  ensureConfig();
  const searchPaths = readLines(SEARCH_PATHS_FILE);
  const bareRepos: string[] = [];

  for (const raw of searchPaths) {
    const dir = resolve(expandTilde(raw));
    if (!existsSync(dir)) continue;

    let entries: string[];
    try {
      entries = readdirSync(dir);
    } catch {
      continue;
    }

    for (const entry of entries) {
      if (entry.endsWith(".git")) {
        const candidate = join(dir, entry);
        try {
          const isBare = git("rev-parse --is-bare-repository", candidate);
          if (isBare === "true") {
            bareRepos.push(candidate);
          }
        } catch {
          // Not a git repo, skip
        }
      }
    }
  }

  return bareRepos;
}

const MERGE_AGE_DAYS = 30;

function cleanupRepo(
  bareDir: string,
  dryRun: boolean,
  force: boolean
): number {
  const repoName = basename(bareDir, ".git");
  const workDir = dirname(bareDir);

  info(`\nChecking ${repoName} (${bareDir})`);

  const worktrees = parseWorktreeList(bareDir);

  // Read pins
  const pins = readLines(PINS_FILE);
  const pinnedPaths = new Set<string>();
  for (const line of pins) {
    const idx = line.indexOf(":");
    if (idx > 0) pinnedPaths.add(line.slice(idx + 1));
  }

  // The "main" worktree folder
  const mainPath = join(workDir, "main");

  let removed = 0;

  for (const wt of worktrees) {
    // Skip the bare dir itself
    if (wt.path === bareDir) continue;

    // Skip the main worktree
    if (wt.path === mainPath) continue;

    // Skip pinned worktrees
    if (pinnedPaths.has(wt.path)) {
      info(`  skip (pinned): ${basename(wt.path)} [${wt.branch}]`);
      continue;
    }

    // Check PR status via gh
    let mergedAt: string | null = null;
    let state: string | null = null;
    try {
      const prJson = execSync(
        `gh pr view ${wt.branch} --json mergedAt,state`,
        {
          cwd: bareDir,
          encoding: "utf-8",
          stdio: ["pipe", "pipe", "pipe"],
        }
      ).trim();
      const pr = JSON.parse(prJson);
      state = pr.state;
      mergedAt = pr.mergedAt;
    } catch {
      info(`  skip (no PR): ${basename(wt.path)} [${wt.branch}]`);
      continue;
    }

    if (state !== "MERGED" || !mergedAt) {
      info(`  skip (${state?.toLowerCase() || "unknown"}): ${basename(wt.path)} [${wt.branch}]`);
      continue;
    }

    const mergedDate = new Date(mergedAt);
    const ageDays = (Date.now() - mergedDate.getTime()) / (1000 * 60 * 60 * 24);

    if (ageDays < MERGE_AGE_DAYS) {
      info(
        `  skip (merged ${Math.floor(ageDays)}d ago, < ${MERGE_AGE_DAYS}d): ${basename(wt.path)} [${wt.branch}]`
      );
      continue;
    }

    info(
      `  ${dryRun ? "would remove" : "removing"}: ${basename(wt.path)} [${wt.branch}] (merged ${Math.floor(ageDays)}d ago)`
    );

    if (!dryRun) {
      const forceFlag = force ? " --force" : "";
      try {
        execSync(`git worktree remove${forceFlag} ${wt.path}`, {
          cwd: bareDir,
          stdio: "inherit",
        });
        // Also delete the local branch
        try {
          git(`branch -d ${wt.branch}`, bareDir);
          info(`  deleted branch: ${wt.branch}`);
        } catch {
          info(`  branch ${wt.branch} already gone or not fully merged locally`);
        }
        removed++;
      } catch {
        console.error(`  failed to remove ${wt.path}`);
      }
    } else {
      removed++;
    }
  }

  return removed;
}

function cmdCleanup(args: string[]) {
  const all = args.includes("--all");
  const dryRun = args.includes("--dry-run");
  const force = args.includes("--force");

  if (dryRun) info("Dry run mode — no changes will be made\n");

  let totalRemoved = 0;

  if (all) {
    const bareRepos = findBareRepos();
    if (bareRepos.length === 0) {
      info("No bare repos found in search paths.");
      return;
    }
    info(`Found ${bareRepos.length} bare repo(s)`);
    for (const bareDir of bareRepos) {
      totalRemoved += cleanupRepo(bareDir, dryRun, force);
    }
  } else {
    let bareDir: string;
    try {
      const repoInfo = resolveBareRepo();
      bareDir = repoInfo.bareDir;
    } catch {
      die("Not inside a git repository");
    }

    if (!bareDir) {
      die("Not inside a bare repo or worktree.");
    }

    totalRemoved = cleanupRepo(bareDir, dryRun, force);
  }

  info(
    `\n${dryRun ? "Would remove" : "Removed"} ${totalRemoved} worktree(s)`
  );
}

// --- Dispatch ---

function main() {
  const [cmd, ...args] = process.argv.slice(2);

  if (!cmd || cmd === "--help" || cmd === "-h") {
    console.log(`gw - Unified Git Worktree CLI

Usage: gw <command> [args]

Commands:
  init <git-url> [target-dir]   Clone bare + fix refspec + create main worktree
  add <branch-name>             Create worktree with smart folder naming
  list                          List worktrees, mark pinned one
  remove <name> [--force]       Remove worktree safely
  cleanup [--all] [--dry-run] [--force]
                                Remove worktrees with merged PRs (30+ days)
  pin                           Pin current worktree as default for repo
  register [path]               Add path to tmux-sessionizer search paths
  unregister [path]             Remove path from search paths
  paths                         Show registered search paths`);
    process.exit(0);
  }

  switch (cmd) {
    case "init":
      return cmdInit(args);
    case "add":
      return cmdAdd(args);
    case "list":
    case "ls":
      return cmdList();
    case "remove":
    case "rm":
      return cmdRemove(args);
    case "cleanup":
      return cmdCleanup(args);
    case "pin":
      return cmdPin();
    case "register":
      return cmdRegister(args);
    case "unregister":
      return cmdUnregister(args);
    case "paths":
      return cmdPaths();
    default:
      die(`Unknown command: ${cmd}. Run 'gw --help' for usage.`);
  }
}

main();
