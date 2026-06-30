# Create Feature Workflow

## Purpose
To design, implement, test, and document new system capabilities systematically.

## When to Use
- When building a new feature, endpoint, page, or service.

## Required Prerequisite Skills
- `architecture-thinking` (to design before writing code)
- `documentation-first` (to write specs and contracts first)
- `testing-first` (to write test cases prior to implementation)
- `security-first` (to perform threat modeling on the feature design)
- `verification-before-completion` (to validate the final implementation)

## Expected Inputs
- A feature ticket containing requirements and acceptance criteria.
- Target codebase access.

## Execution Workflow
1. **Design Architecture**: Apply `architecture-thinking` to plan system boundaries, DB schemas, and service interfaces. Write an ADR if required.
2. **Perform Threat Modeling**: Use `security-first` to evaluate threat vectors on the new interfaces.
3. **Write API/User Contracts**: Apply `documentation-first` to write the OpenAPI specs, README, or schema docs. Commit them.
4. **Write Tests**: Apply `testing-first`. Write the unit and integration tests based on acceptance criteria. Verify they fail (Red).
5. **Implement Code**: Write the minimal code to satisfy the contracts and pass the tests. Ensure standards (`coding-style`, `backend-standards`, `frontend-standards`) are met.
6. **Verify and Clean**: Execute `verification-before-completion`. Review the diff, run manual verification, and audit logs.

## Expected Outputs
- Working feature code with comprehensive unit and integration tests.
- Updated documentation and API specs matching the implementation.
- Passing CI quality gates.

## Completion Checklist
- [ ] Architecture design and threat modeling are completed and documented.
- [ ] API schemas and user documentation are written and committed.
- [ ] Automated tests cover all major scenarios and pass.
- [ ] Code conforms to coding style, security, and performance standards.
- [ ] Feature is verified locally and passes all verification gates.
