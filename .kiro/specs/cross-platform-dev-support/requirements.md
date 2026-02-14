# Requirements Document: Cross-Platform Development Support

## Introduction

This specification defines requirements for enabling native development support for ControlR on Linux and macOS platforms. Currently, the project is primarily configured for Visual Studio on Windows. This feature will ensure developers on Linux and macOS can use VS Code and JetBrains Rider with the same level of productivity and tooling support as Windows developers.

## Glossary

- **VS Code**: Visual Studio Code, a cross-platform code editor by Microsoft
- **Rider**: JetBrains Rider, a cross-platform .NET IDE
- **Aspire**: .NET Aspire, Microsoft's orchestration and observability framework for distributed applications
- **AppHost**: The .NET Aspire orchestration project (ControlR.Web.AppHost)
- **Hot Reload**: .NET's capability to apply code changes without restarting the application
- **Launch Configuration**: IDE-specific configuration files that define how to run and debug applications
- **Task**: An automated command or script that can be executed from within an IDE
- **Compound Configuration**: A launch configuration that starts multiple processes simultaneously
- **InMemory Database**: Entity Framework Core's in-memory database provider for testing without PostgreSQL

## Requirements

### Requirement 1: VS Code Development Environment

**User Story:** As a developer using VS Code on Linux or macOS, I want comprehensive launch configurations and tasks, so that I can build, run, debug, and test the full ControlR stack without manual command-line intervention.

#### Acceptance Criteria

1. WHEN a developer opens the project in VS Code, THE System SHALL provide tasks for building the solution, individual projects, and running tests
2. WHEN a developer uses the "Full Stack (Debug)" launch configuration, THE System SHALL start the web server, agent, and desktop client with debugger attached
3. WHEN a developer uses the "Full Stack (Hot Reload)" launch configuration, THE System SHALL start all components with hot reload enabled for rapid iteration
4. WHEN a developer runs the test task, THE System SHALL execute all xUnit tests and display results in the VS Code test explorer
5. WHEN a developer uses launch configurations, THE System SHALL automatically build dependencies before launching

### Requirement 2: JetBrains Rider Development Environment

**User Story:** As a developer using Rider on Linux or macOS, I want native run configurations, so that I can use Rider's integrated debugging and profiling tools effectively.

#### Acceptance Criteria

1. WHEN a developer opens the project in Rider, THE System SHALL provide run configurations for all major components
2. WHEN a developer uses the "Full Stack (Debug)" configuration, THE System SHALL start all components with Rider's debugger attached
3. WHEN a developer uses the "Full Stack (Hot Reload)" configuration, THE System SHALL enable hot reload for supported projects
4. WHEN a developer runs tests in Rider, THE System SHALL integrate with Rider's test runner and display results in the test explorer
5. WHEN a developer uses Aspire AppHost configuration, THE System SHALL launch the Aspire Dashboard and all orchestrated services

### Requirement 3: .NET Aspire Cross-Platform Support

**User Story:** As a developer on Linux or macOS, I want .NET Aspire to work correctly on my platform, so that I can use the same orchestration and observability tools as Windows developers.

#### Acceptance Criteria

1. WHEN a developer runs the AppHost project, THE System SHALL start PostgreSQL, the web server, and the agent with proper dependency ordering
2. WHEN Aspire Dashboard starts, THE System SHALL make it accessible at the configured port with authentication
3. WHEN services are orchestrated by Aspire, THE System SHALL properly configure environment variables for inter-service communication
4. WHEN a developer views the Aspire Dashboard, THE System SHALL display logs, traces, and metrics from all running services
5. WHEN Aspire containers fail to start, THE System SHALL provide clear error messages indicating the cause

### Requirement 4: Database Configuration Options

**User Story:** As a developer on Linux or macOS, I want flexible database configuration options, so that I can develop without requiring Docker or PostgreSQL installation.

#### Acceptance Criteria

1. WHEN a developer sets the InMemory database option, THE System SHALL use Entity Framework Core's in-memory provider instead of PostgreSQL
2. WHEN a developer uses Docker Compose, THE System SHALL start PostgreSQL with persistent volumes and proper networking
3. WHEN a developer uses a local PostgreSQL installation, THE System SHALL connect using environment variables or configuration files
4. WHEN database migrations are needed, THE System SHALL provide clear instructions for applying them on each platform
5. WHEN the database connection fails, THE System SHALL provide actionable error messages with troubleshooting steps

### Requirement 5: Platform-Specific Prerequisites Documentation

**User Story:** As a developer setting up ControlR on Linux or macOS for the first time, I want clear documentation of prerequisites and dependencies, so that I can configure my development environment correctly.

#### Acceptance Criteria

1. WHEN a developer reads the setup documentation, THE System SHALL list all required software with version numbers for Linux
2. WHEN a developer reads the setup documentation, THE System SHALL list all required software with version numbers for macOS
3. WHEN a developer follows the setup guide, THE System SHALL provide installation commands for common package managers (apt, brew, etc.)
4. WHEN platform-specific dependencies are required, THE System SHALL explain why they are needed and how to verify installation
5. WHEN optional dependencies exist, THE System SHALL clearly mark them as optional and explain their benefits

### Requirement 6: Build and Test Workflows

**User Story:** As a developer on Linux or macOS, I want streamlined build and test workflows, so that I can verify my changes quickly without memorizing complex commands.

#### Acceptance Criteria

1. WHEN a developer runs the build task, THE System SHALL compile the entire solution and report any errors
2. WHEN a developer runs the test task, THE System SHALL execute all unit and integration tests with coverage reporting
3. WHEN a developer runs the quick build task, THE System SHALL build with minimal verbosity for fast feedback
4. WHEN a developer runs project-specific build tasks, THE System SHALL build only the specified project and its dependencies
5. WHEN build or test failures occur, THE System SHALL display errors in the IDE's problem panel with file locations

### Requirement 7: Debugging Support for All Project Types

**User Story:** As a developer on Linux or macOS, I want full debugging support for all project types, so that I can troubleshoot issues in the web server, agent, desktop client, and Blazor WebAssembly code.

#### Acceptance Criteria

1. WHEN a developer sets breakpoints in the web server code, THE System SHALL pause execution and allow variable inspection
2. WHEN a developer sets breakpoints in the agent code, THE System SHALL pause execution and allow step-through debugging
3. WHEN a developer sets breakpoints in the desktop client code, THE System SHALL pause execution and allow UI state inspection
4. WHEN a developer debugs Blazor WebAssembly code, THE System SHALL enable browser-based debugging with source maps
5. WHEN multiple processes are being debugged, THE System SHALL allow switching between debug sessions without losing context

### Requirement 8: Hot Reload Configuration

**User Story:** As a developer on Linux or macOS, I want hot reload to work for supported project types, so that I can see changes immediately without restarting the application.

#### Acceptance Criteria

1. WHEN a developer modifies Blazor component code, THE System SHALL apply changes without restarting the server
2. WHEN a developer modifies CSS or JavaScript files, THE System SHALL reload the browser automatically
3. WHEN a developer modifies backend API code, THE System SHALL apply changes using .NET hot reload when possible
4. WHEN hot reload cannot apply a change, THE System SHALL provide a clear message indicating a restart is required
5. WHEN hot reload is enabled, THE System SHALL not significantly impact application performance

### Requirement 9: Development Environment Verification

**User Story:** As a developer on Linux or macOS, I want a way to verify my development environment is configured correctly, so that I can identify and fix issues before starting development.

#### Acceptance Criteria

1. WHEN a developer runs the verification script, THE System SHALL check for all required software installations
2. WHEN a developer runs the verification script, THE System SHALL verify .NET SDK version compatibility
3. WHEN a developer runs the verification script, THE System SHALL test database connectivity
4. WHEN a developer runs the verification script, THE System SHALL verify Docker is running if Docker-based workflows are used
5. WHEN verification fails, THE System SHALL provide specific remediation steps for each failed check

### Requirement 10: Documentation and Getting Started Guide

**User Story:** As a new developer on Linux or macOS, I want comprehensive getting started documentation, so that I can go from zero to running the full stack in minimal time.

#### Acceptance Criteria

1. WHEN a developer reads the getting started guide, THE System SHALL provide step-by-step instructions for environment setup
2. WHEN a developer follows the guide, THE System SHALL include commands for installing prerequisites on Ubuntu, Debian, Fedora, and macOS
3. WHEN a developer completes the setup, THE System SHALL provide instructions for running the full stack for the first time
4. WHEN a developer encounters common issues, THE System SHALL provide a troubleshooting section with solutions
5. WHEN a developer wants to contribute, THE System SHALL link to coding standards and contribution guidelines
