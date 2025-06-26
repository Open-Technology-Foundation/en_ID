# Contributing to en_ID Locale

Thank you for your interest in contributing to the English locale for Indonesia!

## How to Contribute

1. **Fork the Repository**
   - Fork this repository to your GitHub account
   - Clone your fork locally

2. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make Your Changes**
   - Edit the locale file in `localedata/en_ID`
   - Update documentation if needed
   - Add tests for new features

4. **Test Your Changes**
   ```bash
   make test
   ```

5. **Commit Your Changes**
   ```bash
   git commit -m "Brief description of changes"
   ```

6. **Push and Create Pull Request**
   ```bash
   git push origin feature/your-feature-name
   ```

## Guidelines

### Locale File Format

- Use Unicode code points (e.g., `<U0041>` for 'A')
- Follow GNU libc locale format specifications
- Maintain consistent indentation and formatting
- Add comments to explain non-obvious choices

### Testing

All changes must pass existing tests and include new tests where applicable:

```bash
# Run all tests
make test

# Test specific locale category
./tests/test_en_ID.sh LC_TIME
```

### Documentation

- Update README.md if adding new features
- Document rationale for significant changes
- Keep examples current and accurate

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help maintain a welcoming environment

## Reporting Issues

Please use the GitHub issue tracker to report:
- Bugs or incorrect behavior
- Missing features
- Documentation improvements
- Questions about implementation

Include:
- Clear description of the issue
- Steps to reproduce (if applicable)
- Expected vs actual behavior
- System information (OS, locale version)

## Review Process

1. All contributions require review before merging
2. Changes affecting core functionality need two approvals
3. Documentation-only changes need one approval
4. CI tests must pass

## Questions?

Feel free to open an issue for discussion or contact the maintainers at info@yatti.id

Thank you for helping improve the en_ID locale!