# Implementation Plan: Cross-Platform Development Support

## Overview

This implementation plan breaks down the cross-platform development support feature into discrete tasks focused on creating IDE configurations, documentation, scripts, and tests. The approach prioritizes getting the core development workflows functional first, then adding verification and testing capabilities.

## Tasks

- [x] 1. Enhance VS Code configuration files
  - [x] 1.1 Update `.vscode/tasks.json` with comprehensive build and test tasks
    - Add tasks for: clean, restore, build-solution, test-all, test-watch, verify-env
    - Configure problem matchers for build errors
    - Set appropriate working directories and dependencies
    - _Requirements: 1.1, 6.1, 6.2, 6.3, 6.5_
  - [x] 1.2 Update `.vscode/launch.json` with all launch configurations
    - Add individual debug configurations for Server, Agent, Desktop Client
    - Add Aspire AppHost debug configuration
    - Add Blazor WebAssembly debug configuration with browser integration
    - Configure preLaunchTask for all configurations that need building
    - _Requirements: 1.2, 1.3, 1.5, 7.4_
  - [x] 1.3 Create `.vscode/settings.json` with workspace settings
    - Configure recommended file associations
    - Set default terminal shell for different platforms
    - Configure test explorer settings
    - _Requirements: 1.1_
  - [x] 1.4 Create `.vscode/extensions.json` with recommended extensions
    - Add C# Dev Kit, Docker, and other essential extensions
    - Mark required vs optional extensions
    - _Requirements: 1.1_

- [x] 2. Enhance Rider run configurations
  - [x] 2.1 Update existing `.run/Full Stack (Debug).run.xml`
    - Verify all components are included
    - Ensure proper build dependencies
    - _Requirements: 2.1, 2.2_
  - [x] 2.2 Update existing `.run/Full Stack (Hot Reload).run.xml`
    - Configure hot reload settings for supported projects
    - _Requirements: 2.3, 8.1, 8.3_
  - [x] 2.3 Create `.run/Aspire AppHost.run.xml`
    - Configure to run ControlR.Web.AppHost project
    - Set appropriate environment variables
    - _Requirements: 2.5_
  - [x] 2.4 Create `.run/Tests (All).run.xml`
    - Configure to run all test projects
    - Enable coverage collection
    - _Requirements: 2.4_

- [x] 3. Create environment verification script
  - [x] 3.1 Create `scripts/verify-dev-env.sh` with prerequisite checks
    - Check for .NET SDK 10.0+
    - Check for Docker installation and daemon status
    - Check for Docker Compose
    - Check for platform-specific dependencies (X11, GStreamer, etc.)
    - Output pass/fail status with colored output
    - _Requirements: 9.1, 9.2, 9.4_
  - [ ]\* 3.2 Write unit tests for verification script logic
    - Test tool detection logic
    - Test version parsing
    - Test output formatting
    - _Requirements: 9.1, 9.2, 9.4_
  - [ ]\* 3.3 Write property test for verification script
    - **Property 1: Verification script validates all required tools**
    - **Validates: Requirements 9.1**
  - [ ]\* 3.4 Write property test for .NET version checking
    - **Property 2: Verification script checks .NET SDK version**
    - **Validates: Requirements 9.2**
  - [ ]\* 3.5 Write property test for Docker validation
    - **Property 4: Verification script validates Docker daemon**
    - **Validates: Requirements 9.4**

- [x] 4. Implement database configuration flexibility
  - [x] 4.1 Update `ControlR.Web.Server/appsettings.Development.json` with database provider option
    - Add DatabaseProvider setting (InMemory or PostgreSQL)
    - Add connection string templates
    - _Requirements: 4.1, 4.3_
  - [x] 4.2 Modify database registration in `ControlR.Web.Server/Startup/WebApplicationBuilderExtensions.cs`
    - Read DatabaseProvider from configuration
    - Register InMemory provider when configured
    - Register PostgreSQL provider when configured
    - Support connection strings from multiple sources (env vars, appsettings, user secrets)
    - _Requirements: 4.1, 4.3_
  - [ ]\* 4.3 Write unit tests for database provider selection
    - Test InMemory provider registration
    - Test PostgreSQL provider registration
    - Test connection string reading from different sources
    - _Requirements: 4.1, 4.3_
  - [ ]\* 4.4 Write property test for database provider selection
    - **Property 5: Database provider selection based on configuration**
    - **Validates: Requirements 4.1**
  - [ ]\* 4.5 Write property test for connection string configuration
    - **Property 6: Connection string configuration sources**
    - **Validates: Requirements 4.3**

- [x] 5. Update docker-compose configuration for development
  - [x] 5.1 Verify `docker-compose/docker-compose.yml` has persistent volumes
    - Ensure PostgreSQL data volume is configured
    - Verify network configuration
    - _Requirements: 4.2_
  - [x] 5.2 Verify `docker-compose/docker-compose.override.yml` has development settings
    - Ensure Aspire Dashboard is accessible
    - Verify environment variables for development
    - _Requirements: 3.1, 3.2_

- [x] 6. Create comprehensive development documentation
  - [x] 6.1 Create `docs/development/SETUP.md` with getting started guide
    - Overview of development stack
    - Prerequisites section with version numbers
    - Platform-specific setup instructions (Ubuntu, Debian, Fedora, macOS)
    - Installation commands for each package manager
    - Database setup options (Docker, local PostgreSQL, InMemory)
    - First-time run instructions
    - _Requirements: 5.1, 5.2, 5.3, 10.1, 10.2, 10.3_
  - [x] 6.2 Create `docs/development/IDE_SETUP.md` with IDE-specific instructions
    - VS Code setup and recommended extensions
    - Rider setup and plugins
    - How to use launch configurations
    - How to use tasks
    - Debugging tips for each project type
    - _Requirements: 1.1, 2.1, 10.1_
  - [x] 6.3 Create `docs/development/TROUBLESHOOTING.md` with common issues
    - Port conflicts and resolution
    - Docker daemon not running
    - Database connection failures
    - Hot reload not working
    - Aspire Dashboard not accessible
    - Platform-specific issues (X11, Wayland, macOS permissions)
    - _Requirements: 10.4_
  - [x] 6.4 Create `docs/development/DATABASE.md` with database setup details
    - How to use InMemory provider
    - How to use Docker PostgreSQL
    - How to use local PostgreSQL
    - How to apply migrations
    - How to reset database
    - _Requirements: 4.1, 4.2, 4.3, 4.4_
  - [x] 6.5 Update root `README.md` with link to development documentation
    - Add "Development" section
    - Link to SETUP.md
    - Link to contribution guidelines (if they exist)
    - _Requirements: 10.5_

- [x] 7. Checkpoint - Verify configurations work on Linux
  - Ensure all configurations work on Ubuntu 24.04 LTS
  - Test with both VS Code and Rider
  - Verify verification script runs correctly
  - Ask the user if questions arise

- [x] 8. Checkpoint - Verify configurations work on macOS
  - Ensure all configurations work on macOS Sequoia
  - Test with both VS Code and Rider
  - Verify verification script runs correctly
  - Ask the user if questions arise

- [ ]\* 9. Create integration tests for development workflows
  - [ ]\* 9.1 Write integration test for Docker Compose workflow
    - Test that docker-compose up starts all services
    - Test that services are healthy
    - Test that services can communicate
    - _Requirements: 3.1, 4.2_
  - [ ]\* 9.2 Write integration test for Aspire AppHost workflow
    - Test that AppHost starts services in correct order
    - Test that environment variables are configured
    - Test that Aspire Dashboard is accessible
    - _Requirements: 3.1, 3.3_
  - [ ]\* 9.3 Write integration test for InMemory database workflow
    - Test that application starts with InMemory provider
    - Test that migrations apply
    - Test that data persists during application lifetime
    - _Requirements: 4.1_

- [ ]\* 10. Create validation tests for configuration files
  - [ ]\* 10.1 Write unit tests for VS Code configuration validation
    - Test that tasks.json contains required tasks
    - Test that launch.json contains required configurations
    - Test that launch configurations have preLaunchTask where needed
    - _Requirements: 1.1, 1.5_
  - [ ]\* 10.2 Write unit tests for Rider configuration validation
    - Test that required .run.xml files exist
    - Test that configurations reference correct projects
    - _Requirements: 2.1_
  - [ ]\* 10.3 Write unit tests for documentation validation
    - Test that required documentation files exist
    - Test that documentation contains required sections
    - Test that code blocks contain platform-specific commands
    - _Requirements: 5.1, 5.2, 5.3, 10.1, 10.2, 10.3, 10.4_

- [x] 11. Final checkpoint - End-to-end verification
  - Run verification script on clean Linux VM
  - Run verification script on clean macOS system
  - Follow setup guide from scratch on both platforms
  - Verify all launch configurations work
  - Verify hot reload works
  - Verify debugging works
  - Ensure all tests pass
  - Ask the user if questions arise

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Configuration files should be tested on both Linux and macOS before considering complete
- Documentation should be reviewed by someone unfamiliar with the project for clarity
- The verification script is a key deliverable that helps developers self-diagnose issues
- Database flexibility (InMemory option) is important for developers without Docker
