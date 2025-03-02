# Contributing to MLog

We love your input! We want to make contributing to MLog as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## Development Process

We use GitHub to host code, to track issues and feature requests, as well as accept pull requests.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests to ensure they pass (`pytest`)
5. Commit your changes (`git commit -m 'Add some amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## Pull Requests

1. Update the README.md with details of changes if applicable
2. Update examples if needed
3. The PR should work for Python 3.7 and newer
4. Ensure all tests pass

## Testing

Before submitting a PR, please run the tests:

```bash
pytest
```

## Coding Style

We use Black for code formatting and flake8 for linting. Please make sure your code follows these standards:

```bash
black mlog/
flake8 mlog/
```

## License

By contributing, you agree that your contributions will be licensed under the project's MIT License.