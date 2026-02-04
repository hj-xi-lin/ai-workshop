#!/bin/bash
# ============================================================
# Customer Report Skill Installer for Claude Code
# ============================================================

set -e

echo "🚀 Installing Customer Report Skill..."

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Create Claude skills directory with proper structure
SKILL_DIR=~/.claude/skills/customer-report
mkdir -p "$SKILL_DIR"

# Copy skill files (new SKILL.md format)
echo "📁 Copying skill files..."
cp "$SCRIPT_DIR/SKILL.md" "$SKILL_DIR/"
cp "$SCRIPT_DIR/customer_report_generator.py" "$SKILL_DIR/"

# Copy template to Desktop
echo "📄 Copying PowerPoint template..."
cp "$SCRIPT_DIR/Template.pptx" ~/Desktop/

# Check if python-pptx is installed
echo "🐍 Checking Python dependencies..."
if python3 -c "import pptx" 2>/dev/null; then
    echo "   ✓ python-pptx already installed"
else
    echo "   Installing python-pptx..."
    pip3 install python-pptx --break-system-packages --quiet 2>/dev/null || \
    pip3 install python-pptx --user --quiet 2>/dev/null || \
    python3 -m pip install python-pptx --user --quiet 2>/dev/null || \
    echo "   ⚠️  Could not install python-pptx automatically. Please run: pip3 install python-pptx"
fi

# Clean up old format files if they exist
echo "🧹 Cleaning up old skill format..."
rm -f ~/.claude/skills/customer-report.md 2>/dev/null || true
rm -f ~/.claude/skills/customer-report-instructions.md 2>/dev/null || true
rm -f ~/.claude/skills/customer_report_generator.py 2>/dev/null || true

echo ""
echo "============================================================"
echo "✅ Installation complete!"
echo "============================================================"
echo ""
echo "📍 Files installed to:"
echo "   - ~/.claude/skills/customer-report/SKILL.md"
echo "   - ~/.claude/skills/customer-report/customer_report_generator.py"
echo "   - ~/Desktop/Template.pptx"
echo ""
echo "🎯 Usage in Claude Code:"
echo "   /customer-report REWE                      # Last 12 months"
echo "   /customer-report \"Deutsche Bahn\" 6         # Last 6 months"
echo "   /customer-report Lidl 2024-01-01 2024-12-31 # Date range"
echo "   /customer-report REWE Q4 2024              # Specific quarter"
echo "   /customer-report Lidl YTD                  # Year to date"
echo ""
echo "📋 Requirements:"
echo "   - Redshift MCP plugin configured"
echo "   - Access to rds.rep_job_metrics table"
echo ""
