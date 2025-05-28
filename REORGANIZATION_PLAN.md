# Reorganization Plan for Commesse Projects

## Current Issues
1. Mixed project types in root directory
2. No clear separation between companies/employers
3. Utility scripts scattered across multiple directories
4. No distinction between active consulting and legacy projects
5. Current company projects mixed with historical work

## Proposed Structure

```
/Commesse/
├── 01_SquareDivision/           (Current Company)
│   ├── ultralytics/
│   └── SquareDivision/
│
├── 02_Consulting/               (Active Consulting)
│   └── Opto3i-NEW/
│
├── 03_ActiveProjects/           (Other Active Work)
│   ├── Eppos/
│   ├── segment-anything/
│   └── Eidon/
│
├── 04_PreviousCompanies/        (Historical Employment)
│   ├── Opto3i/                  (Direct employment)
│   ├── VideoSystems/
│   └── beanTech/
│
├── 05_SharedLibraries/
│   ├── Global/                  (C# libraries)
│   ├── Tools/                   (Utilities)
│   └── Utils/                   (Additional utilities)
│
├── 06_Scripts/
│   ├── Bat/                     (Windows scripts)
│   ├── Linux/                   (Linux/WSL scripts)
│   └── settings/                (Configurations)
│
├── 07_Archive/
│   ├── Oasis/
│   └── [other inactive projects]
│
├── 08_Personal/
│   ├── Miei/
│   ├── TFR/
│   ├── PiuSicura/
│   └── Manuals/
│
└── _Management/
    ├── .gitignore
    ├── README.md
    ├── PROJECT_OVERVIEW.md
    └── REORGANIZATION_PLAN.md
```

## Reorganization Steps

### Phase 1: Categorization
1. Identify active vs archived projects
2. Determine project dependencies
3. Document customer associations

### Phase 2: Directory Structure
1. Create new directory structure
2. Move projects to appropriate categories
3. Consolidate scattered utilities

### Phase 3: Standardization
1. Standardize project naming conventions
2. Create README files for each major category
3. Update references and paths

### Phase 4: Documentation
1. Document the new structure
2. Create migration guide
3. Update development workflows

## Benefits
- Clear separation between employers/companies
- Easy identification of current vs consulting vs legacy work
- Better intellectual property boundaries
- Simplified billing and time tracking
- Clearer licensing and ownership
- Easier to manage confidentiality requirements

## Considerations
- Maintain backward compatibility for active projects
- Update build scripts and references
- Consider using symbolic links for transition period
- Backup everything before reorganization

## Alternative Approach: Tags/Metadata
Instead of physical reorganization, consider:
- Keeping current structure
- Adding metadata files to each project
- Creating index/catalog system
- Using tags for categorization

This approach minimizes disruption while improving organization.