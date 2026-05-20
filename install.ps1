<#
.SYNOPSIS
    传奇游戏公司法务智能体 - 一键安装脚本（含深度审查输出规范）
.DESCRIPTION
    将技能文件、知识库、CLAUDE.md配置（已集成深度审查输出规范模板）、记忆文件安装到本机Claude Code环境
    安装后智能体自动学习三阶段工作流输出格式，无需额外教授规范输出
#>

$ErrorActionPreference = "Stop"
$PackagePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeSkillsDir = "$env:USERPROFILE\.claude\skills"
$ClaudeProjectsDir = "$env:USERPROFILE\.claude\projects"
$TargetProjectDir = "$ClaudeProjectsDir\D--AI"

Write-Host "=== 法务智能体安装开始 ===" -ForegroundColor Cyan

# === 1. 安装技能文件 ===
Write-Host "[1/5] 安装技能文件..." -ForegroundColor Yellow

# 法务助手.skill
if (Test-Path "$PackagePath\skills\法务助手.skill") {
    $dest = "$ClaudeSkillsDir\法务助手.skill"
    New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
    Copy-Item "$PackagePath\skills\法务助手.skill" $dest -Force
    Write-Host "  ✅ 法务助手.skill → $dest"
}

# 法务专家综合.skill
if (Test-Path "$PackagePath\skills\法务专家综合.skill") {
    $dest = "$ClaudeSkillsDir\法务专家综合.skill"
    Copy-Item "$PackagePath\skills\法务专家综合.skill" $dest -Force
    Write-Host "  ✅ 法务专家综合.skill → $dest"
}

# china-lawyer-analyst 技能库
if (Test-Path "$PackagePath\skills\china-lawyer-analyst") {
    $dest = "$ClaudeSkillsDir\china-lawyer-analyst"
    if (Test-Path $dest) {
        Write-Host "  ⚠️  目标已存在，覆盖中..." -ForegroundColor Yellow
        Remove-Item -Recurse -Force $dest
    }
    Copy-Item -Recurse "$PackagePath\skills\china-lawyer-analyst" $dest
    Write-Host "  ✅ china-lawyer-analyst 知识库 (324个文件, 2.2MB)"
}

# === 2. 安装 CLAUDE.md（项目配置）===
Write-Host "[2/5] 安装项目配置..." -ForegroundColor Yellow

# 确保目标项目目录存在
New-Item -ItemType Directory -Force -Path $TargetProjectDir | Out-Null

# 安装 CLAUDE.md
if (Test-Path "$PackagePath\CLAUDE.md") {
    Copy-Item "$PackagePath\CLAUDE.md" "$TargetProjectDir\CLAUDE.md" -Force
    Write-Host "  ✅ CLAUDE.md → $TargetProjectDir\CLAUDE.md"
}

# 安装 AGENTS.md
if (Test-Path "$PackagePath\project-config\AGENTS.md") {
    Copy-Item "$PackagePath\project-config\AGENTS.md" "$TargetProjectDir\AGENTS.md" -Force
    Write-Host "  ✅ AGENTS.md"
}

# === 3. 安装记忆文件（经验沉淀）===
Write-Host "[3/5] 安装记忆文件..." -ForegroundColor Yellow

$MemoryDir = "$TargetProjectDir\memory"
New-Item -ItemType Directory -Force -Path $MemoryDir | Out-Null

if (Test-Path "$PackagePath\memory") {
    Copy-Item "$PackagePath\memory\*" $MemoryDir -Force -Recurse
    Write-Host "  ✅ 记忆文件 → $MemoryDir"
}

# === 4. 安装参考文档 ===
Write-Host "[4/5] 安装参考文档..." -ForegroundColor Yellow

$DocsDir = "$TargetProjectDir\docs"
New-Item -ItemType Directory -Force -Path $DocsDir | Out-Null

if (Test-Path "$PackagePath\docs") {
    Copy-Item "$PackagePath\docs\*" $DocsDir -Force -Recurse
    Write-Host "  ✅ 文档 → $DocsDir"
}

# === 5. 验证安装 ===
Write-Host "[5/5] 验证安装..." -ForegroundColor Yellow

$checks = @(
    @{Path = "$ClaudeSkillsDir\china-lawyer-analyst\SKILL.md"; Name = "china-lawyer-analyst 技能核心文件"}
    @{Path = "$ClaudeSkillsDir\法务助手.skill"; Name = "法务助手.skill"}
    @{Path = "$TargetProjectDir\CLAUDE.md"; Name = "CLAUDE.md 项目配置"}
    @{Path = "$TargetProjectDir\memory\MEMORY.md"; Name = "记忆文件索引"}
)

$allPass = $true
foreach ($check in $checks) {
    if (Test-Path $check.Path) {
        Write-Host "  ✅ $($check.Name)"
    } else {
        Write-Host "  ❌ $($check.Name) — 未找到" -ForegroundColor Red
        $allPass = $false
    }
}

Write-Host ""
if ($allPass) {
    Write-Host "=== 🎉 安装完成！===" -ForegroundColor Green
    Write-Host "在项目目录下启动 Claude Code 即可自动加载全部法务能力。" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "启动命令：" -ForegroundColor White
    Write-Host "  cd D:\AI" -ForegroundColor Gray
    Write-Host "  claude" -ForegroundColor Gray
} else {
    Write-Host "=== ⚠️ 部分文件安装异常，请检查包完整性 ===" -ForegroundColor Yellow
}
