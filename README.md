# 🤖 AI Workshop - Claude Code Skills

A collection of reusable skills for Claude Code to automate common tasks.

## 📦 Available Skills

### [Customer Report Generator](./skills/customer-report/)

Generate comprehensive customer performance reports with REACH/HIRE split analysis.

```bash
/customer-report REWE
/customer-report "Deutsche Bahn" 6
```

**Features:**
- Automatic data extraction from Redshift
- REACH vs HIRE performance split
- Monthly trending charts (CPA, Applications)
- Professional PowerPoint output using HeyJobs template

[📖 Full Documentation](./skills/customer-report/README.md)

## 🚀 Quick Start

```bash
# Clone this repo
git clone https://github.com/hj-xi-lin/ai-workshop.git

# Install a skill
cd ai-workshop/skills/customer-report
chmod +x install.sh
./install.sh
```

## 📋 Requirements

- [Claude Code](https://claude.ai/claude-code) CLI
- Redshift MCP plugin (for data skills)
- Python 3.x

## 📁 Repository Structure

```
ai-workshop/
├── README.md
└── skills/
    └── customer-report/
        ├── README.md
        ├── install.sh
        ├── customer-report.md
        ├── customer-report-instructions.md
        ├── customer_report_generator.py
        └── Template.pptx
```

## 🤝 Contributing

To add a new skill:

1. Create a folder under `skills/`
2. Include:
   - `README.md` - Documentation
   - `install.sh` - Installation script
   - Skill definition files
3. Submit a pull request

## 📞 Contact

Questions? Contact: xi.lin@heyjobs.de
