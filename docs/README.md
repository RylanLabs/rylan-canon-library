# Documentation

> Part of rylan-patterns-library  
> Extracted from: [rylan-unifi-case-study](https://github.com/RylanLabs/rylan-unifi-case-study)  
> Version: v∞.5.2-production-archive  
> Date: December 19, 2025

**Status**: 🚧 Content extraction in progress

---

## Overview

This directory contains principle documentation and philosophy guides extracted from the rylan-unifi-case-study production repository. These documents explain the *why* behind the patterns and validators in this library.

## Documentation Files

### Core Principles

#### [seven-pillars.md](seven-pillars.md)
The seven fundamental principles for production-grade infrastructure code:
1. Idempotency
2. Error Handling
3. Audit Logging
4. Documentation
5. Validation
6. Reversibility
7. Observability

**Read first** - Foundation for all other patterns.

#### [hellodeolu-v6.md](hellodeolu-v6.md)
Consciousness architecture and discipline framework. Traces the evolution from basic scripting (v1) through production-grade discipline systems (v6). Provides context for how these patterns evolved through real-world usage.

**Read second** - Understanding the journey builds appreciation for the destination.

### Cultural Principles

#### [no-bypass-culture.md](no-bypass-culture.md)
Why shortcuts and workarounds undermine system integrity. How to build a culture where compliance happens naturally, not through enforcement.

Key insights:
- Make the right way the easy way
- Document reasons, not just rules
- Provide accountable escape hatches
- Lead by example

#### [irl-first-approach.md](irl-first-approach.md)
Philosophy of manual discipline before automated enforcement. Why human understanding precedes rigid rules, and how to balance automation with flexibility.

Process framework:
1. Learn principles manually
2. Practice with feedback
3. Validate understanding
4. Introduce automation gradually
5. Maintain human oversight

### Technical Standards

#### [bash-discipline.md](bash-discipline.md)
Production-grade bash scripting standards. Covers:
- Script header requirements
- Error handling patterns (`set -euo pipefail`)
- Function design guidelines
- Variable naming conventions
- ShellCheck compliance
- Documentation standards

**Practical reference** - Use alongside `templates/` and `patterns/`.

## Recommended Reading Order

1. **Start here**: [seven-pillars.md](seven-pillars.md) - Core principles
2. **Context**: [hellodeolu-v6.md](hellodeolu-v6.md) - Evolution story
3. **Culture**: [no-bypass-culture.md](no-bypass-culture.md) - Building discipline
4. **Philosophy**: [irl-first-approach.md](irl-first-approach.md) - Manual before automated
5. **Practice**: [bash-discipline.md](bash-discipline.md) - Technical standards

## How to Use This Documentation

**For learning**:
- Read sequentially to build understanding
- Refer back when implementing patterns
- Study examples alongside principles

**For reference**:
- Jump to specific topics as needed
- Link from code comments to specific sections
- Use as teaching material for teams

**For implementation**:
- Combine with `patterns/` for code examples
- Use `templates/` for starting points
- Run `validators/` to check compliance

## Next Steps

After reading these documents:
1. Explore reusable patterns in [`../patterns/`](../patterns/)
2. Try templates from [`../templates/`](../templates/)
3. Run validators from [`../validators/`](../validators/)
4. Apply principles to your own projects

---

**Note**: All content is being extracted from rylan-unifi-case-study v∞.5.2-production-archive. Check back as documentation is populated.
