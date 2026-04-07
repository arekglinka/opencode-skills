# Questionnaire Reference

## Questions

### 1. Project Name
- **Variable**: `project_name`
- **Type**: Free text
- **Default**: "My Polylith Project"
- **Validation**: Non-empty, 3-100 chars
- **Derived**: `project_slug = project_name.lower().replace(' ', '_')`
- **Derived**: `namespace = project_slug.replace('-', '_')`
- **Prompt**: "What is your project name?"

### 2. Author Name
- **Variable**: `author_name`
- **Type**: Free text
- **Default**: "Your Name"
- **Validation**: Non-empty
- **Prompt**: "What author name should appear in pyproject.toml?"

### 3. Python Version
- **Variable**: `python_version`
- **Type**: Choice
- **Default**: "3.13"
- **Options**: "3.12", "3.13"
- **Validation**: Must be a supported Python version
- **Prompt**: "Which Python version? (3.12 or 3.13)"

### 4. Include Rust Backend
- **Variable**: `include_rust_backend`
- **Type**: Boolean (y/n)
- **Default**: "y"
- **Description**: "Rust-accelerated polynomial evaluation via PyO3. Falls back to NumPy if unavailable."
- **Prompt**: "Include the Rust backend for accelerated evaluation? (y/n)"

### 5. Include Google Workspace Integration
- **Variable**: `include_google_workspace`
- **Type**: Boolean (y/n)
- **Default**: "y"
- **Description**: "Google Drive, Sheets, Tasks integration with OAuth. Requires credentials.json."
- **Prompt**: "Include Google Workspace integration? (y/n)"
- **Note**: If yes, guide user through OAuth credentials setup after generation.

### 6. Include Streamlit App
- **Variable**: `include_streamlit_app`
- **Type**: Boolean (y/n)
- **Default**: "y"
- **Description**: "Interactive visualization dashboard with Plotly charts."
- **Dependency**: Requires the `fitting` component (always core, so always valid).
- **Prompt**: "Include the Streamlit visualization app? (y/n)"

### 7. Include DVC Pipeline
- **Variable**: `include_dvc_pipeline`
- **Type**: Boolean (y/n)
- **Default**: "y"
- **Description**: "DVC data versioning pipeline with generate/fit scripts."
- **Prompt**: "Include the DVC data pipeline? (y/n)"

### 8. Include Examples
- **Variable**: `include_examples`
- **Type**: Boolean (y/n)
- **Default**: "y"
- **Description**: "Jupyter notebook demonstrating polynomial fitting workflow."
- **Prompt**: "Include example notebooks? (y/n)"

### 9. GitHub Repository URL (optional)
- **Variable**: *(not a cookiecutter variable; used post-generation)*
- **Type**: URL, optional
- **Validation**: Must be a valid git remote URL if provided (https or ssh)
- **Prompt**: "Provide a GitHub repo URL to push to, or skip for local-only."
- **Action**: `git remote add origin <URL> && git push -u origin main`

## Validation Rules

| Field | Rule |
|-------|------|
| `project_name` | Non-empty, 3-100 characters |
| `author_name` | Non-empty |
| `python_version` | Must be one of: 3.12, 3.13 |
| `include_*` (5 toggles) | Must be "y" or "n" |
| GitHub URL | Valid git remote if provided; skip allowed |

## Component Dependency Graph

```
fitting (always core)
  └── streamlit_app
```

All optional components are independent of each other. The only dependency is `streamlit_app` on `fitting`, but `fitting` is always included as a core component, so this constraint is always satisfied regardless of user choices.

## Post-Questionnaire Actions

1. **Run cookiecutter** with collected values mapped to template variables.
2. **If `include_google_workspace` = y**: Walk user through creating `credentials.json` and obtaining OAuth tokens.
3. **If GitHub URL provided**: Initialize git repo, add remote, push to main.
4. **If `include_dvc_pipeline` = y**: Run `dvc init` inside the generated project.
