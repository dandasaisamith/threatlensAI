# ThreatLens AI - Complete Folder Structure

```
threatlensAI/
│
├── lib/
│   ├── main.dart                          # App entry point
│   ├── config/
│   │   ├── app_config.dart               # App configuration constants
│   │   ├── supabase_config.dart          # Supabase initialization
│   │   ├── deepseek_config.dart          # DeepSeek API configuration
│   │   ├── logger_config.dart            # Logging configuration
│   │   └── routes_config.dart            # Route configuration
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart        # Global app constants
│   │   │   ├── api_endpoints.dart        # API endpoint constants
│   │   │   └── error_messages.dart       # Error message templates
│   │   │
│   │   ├── errors/
│   │   │   ├── exceptions.dart           # Custom exception classes
│   │   │   ├── failure.dart              # Failure handling
│   │   │   └── error_handler.dart        # Centralized error handling
│   │   │
│   │   ├── extensions/
│   │   │   ├── string_extensions.dart    # String utilities
│   │   │   ├── date_extensions.dart      # Date/time utilities
│   │   │   └── list_extensions.dart      # Collection utilities
│   │   │
│   │   ├── utils/
│   │   │   ├── validators.dart           # Input validation utilities
│   │   │   ├── formatters.dart           # Data formatting utilities
│   │   │   ├── logger.dart               # Logging utility
│   │   │   └── permission_handler.dart   # Permission utilities
│   │   │
│   │   └── storage/
│   │       ├── local_storage.dart        # Local preferences storage
│   │       └── secure_storage.dart       # Secure credential storage
│   │
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── remote/
│   │   │   │   ├── supabase_datasource.dart
│   │   │   │   ├── deepseek_datasource.dart
│   │   │   │   ├── threat_api_datasource.dart
│   │   │   │   └── auth_datasource.dart
│   │   │   │
│   │   │   └── local/
│   │   │       ├── threat_local_datasource.dart
│   │   │       ├── cache_datasource.dart
│   │   │       └── user_local_datasource.dart
│   │   │
│   │   ├── models/
│   │   │   ├── threat/
│   │   │   │   ├── threat_model.dart
│   │   │   │   ├── threat_response.dart
│   │   │   │   └── threat_filter.dart
│   │   │   │
│   │   │   ├── user/
│   │   │   │   ├── user_model.dart
│   │   │   │   ├── user_profile_model.dart
│   │   │   │   └── user_preferences_model.dart
│   │   │   │
│   │   │   ├── analysis/
│   │   │   │   ├── threat_analysis_model.dart
│   │   │   │   ├── risk_score_model.dart
│   │   │   │   └── recommendation_model.dart
│   │   │   │
│   │   │   ├── auth/
│   │   │   │   ├── auth_token_model.dart
│   │   │   │   ├── auth_session_model.dart
│   │   │   │   └── login_response_model.dart
│   │   │   │
│   │   │   ├── deepseek/
│   │   │   │   ├── deepseek_request_model.dart
│   │   │   │   ├── deepseek_response_model.dart
│   │   │   │   └── deepseek_error_model.dart
│   │   │   │
│   │   │   └── common/
│   │   │       ├── pagination_model.dart
│   │   │       ├── error_response_model.dart
│   │   │       └── api_response_model.dart
│   │   │
│   │   └── repositories/
│   │       ├── threat_repository.dart
│   │       ├── user_repository.dart
│   │       ├── auth_repository.dart
│   │       ├── analysis_repository.dart
│   │       └── deepseek_repository.dart
│   │
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── threat/
│   │   │   │   ├── threat_entity.dart
│   │   │   │   ├── threat_detail_entity.dart
│   │   │   │   └── threat_filter_entity.dart
│   │   │   │
│   │   │   ├── user/
│   │   │   │   ├── user_entity.dart
│   │   │   │   ├── user_profile_entity.dart
│   │   │   │   └── user_preferences_entity.dart
│   │   │   │
│   │   │   ├── analysis/
│   │   │   │   ├── threat_analysis_entity.dart
│   │   │   │   ├── risk_assessment_entity.dart
│   │   │   │   └── remediation_entity.dart
│   │   │   │
│   │   │   └── auth/
│   │   │       ├── auth_user_entity.dart
│   │   │       └── auth_session_entity.dart
│   │   │
│   │   ├── repositories/
│   │   │   ├── threat_repository_interface.dart
│   │   │   ├── user_repository_interface.dart
│   │   │   ├── auth_repository_interface.dart
│   │   │   ├── analysis_repository_interface.dart
│   │   │   └── deepseek_repository_interface.dart
│   │   │
│   │   └── usecases/
│   │       ├── threat/
│   │       │   ├── get_threats_usecase.dart
│   │       │   ├── get_threat_detail_usecase.dart
│   │       │   ├── filter_threats_usecase.dart
│   │       │   ├── search_threats_usecase.dart
│   │       │   └── mark_threat_as_read_usecase.dart
│   │       │
│   │       ├── user/
│   │       │   ├── get_user_profile_usecase.dart
│   │       │   ├── update_user_profile_usecase.dart
│   │       │   ├── get_user_preferences_usecase.dart
│   │       │   └── update_user_preferences_usecase.dart
│   │       │
│   │       ├── auth/
│   │       │   ├── login_usecase.dart
│   │       │   ├── logout_usecase.dart
│   │       │   ├── register_usecase.dart
│   │       │   ├── refresh_token_usecase.dart
│   │       │   └── get_current_user_usecase.dart
│   │       │
│   │       ├── analysis/
│   │       │   ├── analyze_threat_usecase.dart
│   │       │   ├── get_risk_assessment_usecase.dart
│   │       │   ├── get_remediation_usecase.dart
│   │       │   └── save_analysis_usecase.dart
│   │       │
│   │       └── deepseek/
│   │           ├── analyze_with_deepseek_usecase.dart
│   │           ├── get_threat_recommendations_usecase.dart
│   │           └── get_risk_insights_usecase.dart
│   │
│   ├── presentation/
│   │   ├── pages/
│   │   │   ├── auth/
│   │   │   │   ├── login_page.dart
│   │   │   │   ├── register_page.dart
│   │   │   │   └── forgot_password_page.dart
│   │   │   │
│   │   │   ├── home/
│   │   │   │   ├── home_page.dart
│   │   │   │   ├── threat_list_page.dart
│   │   │   │   └── dashboard_page.dart
│   │   │   │
│   │   │   ├── threat/
│   │   │   │   ├── threat_detail_page.dart
│   │   │   │   ├── threat_analysis_page.dart
│   │   │   │   ├── threat_search_page.dart
│   │   │   │   └── threat_filter_page.dart
│   │   │   │
│   │   │   ├── analysis/
│   │   │   │   ├── risk_assessment_page.dart
│   │   │   │   ├── remediation_guide_page.dart
│   │   │   │   └── analysis_history_page.dart
│   │   │   │
│   │   │   ├── user/
│   │   │   │   ├── user_profile_page.dart
│   │   │   │   ├── preferences_page.dart
│   │   │   │   └── settings_page.dart
│   │   │   │
│   │   │   └── common/
│   │   │       ├── splash_page.dart
│   │   │       ├── error_page.dart
│   │   │       └── loading_page.dart
│   │   │
│   │   ├── widgets/
│   │   │   ├── common/
│   │   │   │   ├── custom_app_bar.dart
│   │   │   │   ├── custom_button.dart
│   │   │   │   ├── custom_text_field.dart
│   │   │   │   ├── custom_loader.dart
│   │   │   │   ├── error_widget.dart
│   │   │   │   ├── empty_state_widget.dart
│   │   │   │   └── custom_snackbar.dart
│   │   │   │
│   │   │   ├── threat/
│   │   │   │   ├── threat_card.dart
│   │   │   │   ├── threat_list_item.dart
│   │   │   │   ├── threat_detail_header.dart
│   │   │   │   ├── threat_severity_badge.dart
│   │   │   │   ├── threat_timeline.dart
│   │   │   │   └── threat_filter_widget.dart
│   │   │   │
│   │   │   ├── analysis/
│   │   │   │   ├── risk_score_card.dart
│   │   │   │   ├── risk_gauge.dart
│   │   │   │   ├── recommendation_card.dart
│   │   │   │   ├── analysis_summary_widget.dart
│   │   │   │   └── insights_panel.dart
│   │   │   │
│   │   │   └── dashboard/
│   │   │       ├── stats_card.dart
│   │   │       ├── chart_widget.dart
│   │   │       ├── threat_heatmap.dart
│   │   │       └── activity_feed.dart
│   │   │
│   │   ├── providers/
│   │   │   ├── auth/
│   │   │   │   ├── auth_provider.dart
│   │   │   │   ├── login_provider.dart
│   │   │   │   ├── register_provider.dart
│   │   │   │   └── current_user_provider.dart
│   │   │   │
│   │   │   ├── threat/
│   │   │   │   ├── threat_provider.dart
│   │   │   │   ├── threat_list_provider.dart
│   │   │   │   ├── threat_detail_provider.dart
│   │   │   │   ├── threat_filter_provider.dart
│   │   │   │   ├── threat_search_provider.dart
│   │   │   │   └── threat_pagination_provider.dart
│   │   │   │
│   │   │   ├── analysis/
│   │   │   │   ├── threat_analysis_provider.dart
│   │   │   │   ├── risk_assessment_provider.dart
│   │   │   │   ├── deepseek_analysis_provider.dart
│   │   │   │   ├── analysis_history_provider.dart
│   │   │   │   └── recommendations_provider.dart
│   │   │   │
│   │   │   ├── user/
│   │   │   │   ├── user_profile_provider.dart
│   │   │   │   ├── user_preferences_provider.dart
│   │   │   │   └── user_settings_provider.dart
│   │   │   │
│   │   │   ├── common/
│   │   │   │   ├── theme_provider.dart
│   │   │   │   ├── locale_provider.dart
│   │   │   │   ├── connectivity_provider.dart
│   │   │   │   └── loading_provider.dart
│   │   │   │
│   │   │   └── notifiers/
│   │   │       ├── auth_notifier.dart
│   │   │       ├── threat_notifier.dart
│   │   │       ├── analysis_notifier.dart
│   │   │       └── ui_notifier.dart
│   │   │
│   │   └── theme/
│   │       ├── app_theme.dart
│   │       ├── color_scheme.dart
│   │       ├── text_theme.dart
│   │       └── app_sizes.dart
│   │
│   └── services/
│       ├── notification_service.dart
│       ├── analytics_service.dart
│       ├── crash_reporting_service.dart
│       ├── sync_service.dart
│       ├── background_service.dart
│       └── device_info_service.dart
│
├── test/
│   ├── unit/
│   │   ├── repositories/
│   │   ├── usecases/
│   │   ├── providers/
│   │   └── services/
│   │
│   ├── widget/
│   │   ├── pages/
│   │   └── widgets/
│   │
│   └── integration/
│       ├── auth_flow_test.dart
│       ├── threat_analysis_flow_test.dart
│       └── deepseek_integration_test.dart
│
├── assets/
│   ├── images/
│   │   ├── logos/
│   │   ├── icons/
│   │   └── illustrations/
│   │
│   ├── fonts/
│   │   └── [custom fonts]
│   │
│   └── animations/
│       └── [lottie animations]
│
├── docs/
│   ├── architecture.md               # Architecture overview
│   ├── api_contracts.md              # API contract documentation
│   ├── deepseek_integration.md       # DeepSeek integration guide
│   ├── database_schema.md            # Supabase schema documentation
│   ├── providers_guide.md            # Riverpod providers documentation
│   ├── setup_guide.md                # Development setup guide
│   ├── mvp_roadmap.md                # MVP roadmap
│   ├── deployment.md                 # Deployment guide
│   └── contributing.md               # Contributing guidelines
│
├── pubspec.yaml                      # Flutter dependencies
├── pubspec.lock                      # Dependency lock file
├── analysis_options.yaml             # Dart analysis configuration
├── .env.example                      # Environment variables template
├── .gitignore                        # Git ignore rules
├── README.md                         # Project README
├── CHANGELOG.md                      # Changelog
└── LICENSE                           # MIT License
```

## Folder Structure Explanation

### `/lib/config/`
- **Purpose**: Centralized configuration management
- **Includes**: Supabase, DeepSeek API, logging, and routing configurations

### `/lib/core/`
- **Purpose**: Core utilities and infrastructure
- **Includes**: Constants, error handling, extensions, utilities, and storage

### `/lib/data/`
- **Purpose**: Data layer (repositories pattern)
- **Includes**: Datasources, models, and repository implementations

### `/lib/domain/`
- **Purpose**: Domain/Business logic layer
- **Includes**: Entities, abstract repositories, and usecases

### `/lib/presentation/`
- **Purpose**: UI/Presentation layer
- **Includes**: Pages, widgets, Riverpod providers, and theming

### `/lib/services/`
- **Purpose**: Cross-cutting services
- **Includes**: Notifications, analytics, background tasks

### `/test/`
- **Purpose**: Test suite
- **Includes**: Unit, widget, and integration tests

### `/docs/`
- **Purpose**: Project documentation
- **Includes**: Architecture, API, integration, and setup guides
