#!/bin/bash
# ============================================================
# Customer Report Skill Installer for Claude Code
# ============================================================

set -e

echo "🚀 Installing Customer Report Skill..."

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Create Claude skills directory
mkdir -p ~/.claude/skills

# Copy skill files
echo "📁 Copying skill files..."
cp "$SCRIPT_DIR/customer-report.md" ~/.claude/skills/
cp "$SCRIPT_DIR/customer-report-instructions.md" ~/.claude/skills/
cp "$SCRIPT_DIR/customer_report_generator.py" ~/.claude/skills/

# Copy template to Desktop
echo "📄 Copying PowerPoint template..."
cp "$SCRIPT_DIR/Template.pptx" ~/Desktop/

# Check if python-pptx is installed
echo "🐍 Checking Python dependencies..."
if python3 -c "import pptx" 2>/dev/null; then
    echo "   ✓ python-pptx already installed"
else
    echo "   Installing python-pptx..."
    pip3 install python-pptx --user --quiet 2>/dev/null || \
    python3 -m pip install python-pptx --user --quiet 2>/dev/null || \
    echo "   ⚠️  Could not install python-pptx automatically. Please run: pip3 install python-pptx"
fi

echo ""
echo "============================================================"
echo "✅ Installation complete!"
echo "============================================================"
echo ""
echo "📍 Files installed to:"
echo "   - ~/.claude/skills/customer-report.md"
echo "   - ~/.claude/skills/customer-report-instructions.md"
echo "   - ~/.claude/skills/customer_report_generator.py"
echo "   - ~/Desktop/Template.pptx"
echo ""
echo "🎯 Usage in Claude Code:"
echo "   /customer-report REWE"
echo "   /customer-report \"Deutsche Bahn\" 6"
echo "   /customer-report Lidl 24"
echo ""
echo "📋 Requirements:"
echo "   - Redshift MCP plugin configured"
echo "   - Access to rds.rep_job_metrics table"
echo ""
