# Metatranscriptomic Analysis Workflow

This repository contains workflows and tools for metatranscriptomic analysis.

## How to Push Files to This Repository

### Prerequisites
- Git installed on your computer ([Download Git](https://git-scm.com/downloads))
- A GitHub account with access to this repository
- SSH keys or Personal Access Token configured for GitHub authentication

### Step-by-Step Guide

#### 1. Clone the Repository (First Time Only)

If you haven't already cloned the repository to your local machine:

```bash
# Using HTTPS
git clone https://github.com/Skumarerva/Metatranscriptomic_analysis_workflow.git

# Or using SSH (recommended)
git clone git@github.com:Skumarerva/Metatranscriptomic_analysis_workflow.git

# Navigate into the repository directory
cd Metatranscriptomic_analysis_workflow
```

#### 2. Add Your Files

Copy or create your files in the repository directory:

```bash
# Copy files from another location
cp /path/to/your/files/* .

# Or create new files directly
touch your_new_file.txt
```

#### 3. Check What Files Will Be Added

```bash
# See which files have been modified or added
git status

# Review the changes
git diff
```

#### 4. Stage Your Files

```bash
# Add specific files
git add filename1.txt filename2.py

# Or add all files at once
git add .

# Or add files by pattern
git add *.txt
```

#### 5. Commit Your Changes

```bash
# Commit with a descriptive message
git commit -m "Add metatranscriptomic analysis scripts"
```

#### 6. Push to GitHub

```bash
# Push to the main branch
git push origin main

# Or if you're on a different branch
git push origin your-branch-name
```

### Working with Branches

It's a good practice to create a new branch for your changes:

```bash
# Create and switch to a new branch
git checkout -b feature/my-new-feature

# Add and commit your files
git add .
git commit -m "Add my new feature"

# Push the new branch to GitHub
git push origin feature/my-new-feature
```

### Common Issues and Solutions

#### Authentication Failed

If you encounter authentication issues:

**Option 1: Use Personal Access Token (PAT)**
1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Generate a new token with `repo` scope
3. Use the token as your password when pushing

**Option 2: Use SSH Keys**
1. Generate SSH key: `ssh-keygen -t ed25519 -C "your_email@example.com"`
2. Add SSH key to GitHub: Settings → SSH and GPG keys → New SSH key
3. Clone using SSH URL instead of HTTPS

#### Permission Denied

If you get "Permission denied" errors:
- Ensure you have write access to the repository
- Contact the repository owner to grant you collaborator access

#### Merge Conflicts

If you encounter merge conflicts:

```bash
# Pull the latest changes first
git pull origin main

# Resolve any conflicts in your editor
# Then commit the resolved changes
git add .
git commit -m "Resolve merge conflicts"
git push origin main
```

### Best Practices

1. **Pull before push**: Always pull the latest changes before pushing
   ```bash
   git pull origin main
   ```

2. **Commit often**: Make small, frequent commits with clear messages

3. **Use .gitignore**: Don't commit unnecessary files (temporary files, large data files, etc.)

4. **Write clear commit messages**: Describe what changes you made and why

5. **Review before pushing**: Use `git diff` and `git status` to review changes

### Getting Help

- Git documentation: https://git-scm.com/doc
- GitHub guides: https://guides.github.com/
- Git cheat sheet: https://education.github.com/git-cheat-sheet-education.pdf

### Quick Reference

```bash
# Basic workflow
git pull origin main          # Get latest changes
git add .                     # Stage all changes
git commit -m "Your message"  # Commit changes
git push origin main          # Push to GitHub

# Check status
git status                    # See modified files
git log --oneline            # View commit history

# Undo changes
git checkout -- filename     # Discard changes to a file
git reset HEAD filename      # Unstage a file
git reset --soft HEAD~1      # Undo last commit (keep changes)
```

## Repository Structure

```
Metatranscriptomic_analysis_workflow/
├── README.md         # This file
├── .gitignore       # Files to ignore
└── ...              # Your workflow files here
```

## Contributing

When contributing to this repository:

1. Create a new branch for your changes
2. Make your changes and test them
3. Commit with clear, descriptive messages
4. Push your branch and create a Pull Request
5. Wait for review and address any feedback

## License

Please add license information here if applicable.

## Contact

For questions or issues, please open an issue on GitHub or contact the repository maintainer.
