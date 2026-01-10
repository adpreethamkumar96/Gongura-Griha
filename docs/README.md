# Gongura-Griha Documentation

> **These documents are SACRED** - All implementation decisions must align with the specifications defined herein. Any deviation requires explicit approval and documentation.

---

## Current Status

**Phase 1 Complete** - Full UI implementation with mock data. See [FRONTEND_IMPLEMENTATION.md](./FRONTEND_IMPLEMENTATION.md) for details.

---

## Documentation Index

### Implementation (Source of Truth)

| Document | Description | Key Contents |
|----------|-------------|--------------|
| [FRONTEND_IMPLEMENTATION.md](./FRONTEND_IMPLEMENTATION.md) | **Current implementation guide** | All screens, components, routes, data |

### Planning & Design

| Document | Description | Key Contents |
|----------|-------------|--------------|
| [PROJECT_OVERVIEW.md](./PROJECT_OVERVIEW.md) | Project vision, scope & goals | Mission, target audience, KPIs, tech decisions |
| [REQUIREMENTS.md](./REQUIREMENTS.md) | Functional & non-functional requirements | All features with acceptance criteria |
| [TECHNICAL_ARCHITECTURE.md](./TECHNICAL_ARCHITECTURE.md) | System design & architecture | Architecture diagrams, tech stack, patterns |
| [FEATURE_SPECIFICATIONS.md](./FEATURE_SPECIFICATIONS.md) | Detailed UI/UX specifications | Screen layouts, interactions, flows |
| [UI_UX_GUIDELINES.md](./UI_UX_GUIDELINES.md) | Design system & guidelines | Colors, typography, components |

### Backend (Phase 2)

| Document | Description | Key Contents |
|----------|-------------|--------------|
| [DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md) | Data models & relationships | Tables, ERD, SQL definitions |
| [API_SPECIFICATIONS.md](./API_SPECIFICATIONS.md) | REST API contracts | Endpoints, requests, responses |
| [PAYMENT_INTEGRATION.md](./PAYMENT_INTEGRATION.md) | Razorpay integration guide | Payment flows, implementation |

### Development & Deployment

| Document | Description | Key Contents |
|----------|-------------|--------------|
| [DEVELOPMENT_GUIDELINES.md](./DEVELOPMENT_GUIDELINES.md) | Coding standards & practices | Code style, Git workflow, testing |
| [SECURITY_GUIDELINES.md](./SECURITY_GUIDELINES.md) | Security requirements | Auth, data protection, compliance |
| [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) | Deployment procedures | CI/CD, app stores, infrastructure |

---

## Quick Reference

### Technology Stack

| Layer | Technology | Status |
|-------|------------|--------|
| **Mobile App** | Flutter 3.x + Dart | Implemented |
| **Navigation** | GoRouter | Implemented |
| **State Management** | StatefulWidget (Phase 1) / BLoC (Phase 2) | Phase 1 Complete |
| **Localization** | flutter_localizations + ARB | Implemented |
| **Backend** | Node.js + Express | Phase 2 |
| **Database** | PostgreSQL 15 | Phase 2 |
| **Payment** | Razorpay | Phase 2 |
| **Push Notifications** | Firebase Cloud Messaging | Phase 2 |

### Key Decisions

1. **Flutter over React Native** - Superior performance, UI consistency, type safety
2. **GoRouter for Navigation** - Declarative routing, deep linking support
3. **Razorpay over Stripe** - Native UPI support, zero UPI fees, faster settlements
4. **PostgreSQL over MongoDB** - Strong consistency for e-commerce transactions
5. **Feature-First Architecture** - Modular structure for scalability

---

## Development Workflow

```
1. Read relevant documentation
2. Create feature branch
3. Implement following guidelines
4. Write tests
5. Create PR with documentation
6. Code review
7. Merge to develop
8. Deploy to staging
9. QA testing
10. Deploy to production
```

---

## Document Maintenance

- Documents should be updated when requirements change
- All changes must be reviewed and approved
- Version history should be maintained
- Last updated date must be current

---

*Maintained by: Gongura-Griha Development Team*
*Last Updated: January 2026*
