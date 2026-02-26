# Git Workflow Strategy - March to 500 Project

## Branch Structure

### `main` Branch
- **Purpose:** Production-ready code that is live on march.pithyprint.com
- **Protection:** Only merge from `development` after thorough testing
- **Deployment:** Automatically deployed to GitHub Pages
- **Data Updates:** Can accept quick data.json updates (file is in .gitignore, pushed directly)

### `development` Branch  
- **Purpose:** Integration branch for new features and improvements
- **Testing:** Test here before merging to main
- **Workflow:** Create feature branches from here, merge back when complete

### Feature Branches (Optional)
- **Naming:** `feature/description` (e.g., `feature/milestones`)
- **Purpose:** Isolated development of specific features
- **Lifecycle:** Created from `development`, merged back when complete

## Standard Workflow

1. **Start New Feature:**
   ```bash
   git checkout development
   git pull origin development
   git checkout -b feature/feature-name
   ```

2. **Development:**
   - Make changes and commit regularly
   - Keep commits focused and descriptive
   
3. **Testing:**
   ```bash
   git checkout development
   git merge feature/feature-name
   # Test thoroughly on development branch
   ```

4. **Release to Production:**
   ```bash
   git checkout main
   git merge development
   git push origin main
   ```

5. **Quick Data Updates (data.json only):**
   - data.json is in .gitignore (not tracked by git)
   - Update the file directly on main
   - No commit or push required
   - Changes reflect live within 30 seconds via auto-refresh

## Data Management

### data.json - NOT Version Controlled

- **File:** `data.json` (in .gitignore)
- **Purpose:** Live data source for member counts and milestones
- **Updates:** Direct file edits, no git commits
- **Deployment:** Changes reflected immediately on live site
- **Advantages:** 
  - Separates code (version controlled) from data (dynamic)
  - Enables instant data updates without code deployment
  - Keeps git history clean of data changes

### Example Update Flow

```bash
# Edit data.json locally
nano data.json

# Changes live immediately (within 30 seconds)
# No git commands needed!
```

## Current Status

- **main:** Stable production version with auto-refresh and cache control
- **development:** To be created for feature development
- **data.json:** Decoupled from git via .gitignore

## Best Practices

- Always pull latest changes before starting work
- Test changes on development before merging to main  
- Keep development and main in sync
- Use descriptive commit messages
- Document major changes in this file or project documentation
- Remember: code commits to git, data updates bypass git
