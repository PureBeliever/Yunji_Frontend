
项目结构采用“Feature-First”方式，并结合 Clean Architecture 原则：

```
lib/
├── core/ # 核心共享代码（不放 Controller）
│ ├── config/ # 新增：环境配置（如 env.dart 或 flavors.dart，用于 API 密钥等）
│ ├── constants/ # 常量（如颜色、字符串、API 端点）
│ ├── controllers/ # 新增建议：如果全局控制器多，可移至此处（例如 theme_controller.dart）
│ ├── models/ # 新增建议：共享实体模型（如 User 模型，跨模块使用）
│ ├── services/ # 服务类（如 API 客户端、存储服务），可注入到 Controller
│ ├── utils/ # 工具函数（如日期格式化、网络检查）
│ └── widgets/ # 共享 UI 组件（如自定义按钮、加载指示器）
├── features/ # 按功能模块组织（推荐用于中大型项目）
│ ├── auth/ # 认证模块
│ │ ├── data/ # 数据层：Repository、API models
│ │ │ └── auth_repository.dart
│ │ ├── domain/ # 领域层：Entities、Use Cases
│ │ │ ├── entities/
│ │ │ │ └── auth_entity.dart
│ │ │ └── usecases/ # 新增：显式用例文件夹
│ │ │     └── login_usecase.dart # 示例用例
│ │ ├── presentation/ # 表示层：页面、Controller
│ │ │ ├── bindings/ # 新增：绑定类，用于依赖注入
│ │ │ │ └── auth_bindings.dart # 例如 implements Bindings
│ │ │ ├── controllers/ # GetxController 放置在这里
│ │ │ │ └── auth_controller.dart # 核心 Controller
│ │ │ ├── pages/ # 页面文件
│ │ │ │ └── login_page.dart
│ │ │ └── widgets/ # 模块专属 UI 组件
│ │ └── auth_module.dart # 模块入口：定义路由和 Bindings
│ ├── home/ # 首页模块
│   ├── data/ # 数据层
│   ├── domain/ # 领域层
│   │ ├── entities/
│   │ └── usecases/ # 新增
│   ├── presentation/ # 表示层
│   │ ├── bindings/ # 新增
│   │ ├── controllers/
│   │ │ └── home_controller.dart
│   │ ├── pages/
│   │ │ └── home_page.dart
│   │ └── widgets/
│   └── home_module.dart # 模块入口
├── controllers/ # 全局 Controller（如果未移至 core/，例如 theme_controller.dart）
├── main.dart # 应用入口：初始化全局 Bindings
├── routes.dart # 全局路由配置
└── test/ # 新增：测试文件夹（可按模块组织测试文件，如 auth_repository_test.dart）


## 说明
- **core/**：存放应用级共享代码，如常量、服务和通用组件。不包含任何 GetxController。
- **features/**：按功能模块划分，每个模块包含 `data/`（数据处理）、`domain/`（业务逻辑）、`presentation/`（UI 和 Controller）。
- **controllers/**：仅存放全局 Controller（如 `theme_controller.dart`），用于跨模块共享逻辑。
- **main.dart**：初始化全局依赖（如 GetX 的 Bindings）和启动应用。
- **routes.dart**：集中管理路由配置，通常使用 `GetPage` 定义。

- 模块化设计便于维护和扩展。
- 符合 Clean Architecture，分离关注点。
- 适合团队协作，减少代码冲突。
- GetxController 按模块放置，生命周期管理清晰。
```

