# GitHub Actions 工作流说明

本仓库包含 4 个自动化工作流，用于管理上游同步、固件跟踪和构建验证。

## 工作流概览

### 1. 上游同步工作流 (sync-upstream.yml)

**运行时间**: 每天凌晨 4:00 (UTC)  
**手动触发**: 支持

**功能**:
- 自动同步 `openwrt/openwrt` 主分支的更新
- 智能冲突解决:
  - 无冲突: 自动合并并推送
  - ath11k-firmware/Makefile 冲突: 始终保持本地版本（该文件从 VIKINGYFY/ath11k-firmware-ddwrt.git 单独跟踪）
  - GL-AXT1800 设备相关冲突: 创建 Issue 通知维护者，不自动解决
  - 其他设备添加或通用更新: 接受上游更改，但验证不会破坏 GL-AXT1800 支持
- 内核主版本变化检测: 当内核主版本号变化时（如 6.12→6.18），创建 Issue 通知
- GL-AXT1800 设备支持验证: 合并后自动验证关键文件未被删除

**Issue 标签**: `upstream-sync`, `kernel-update`

### 2. ath11k 固件跟踪工作流 (sync-ath11k-firmware.yml)

**运行时间**: 每天凌晨 5:00 (UTC)  
**手动触发**: 支持

**功能**:
- 跟踪 `VIKINGYFY/ath11k-firmware-ddwrt.git` 的最新提交
- 检测固件更新
- 自动更新 `package/firmware/ath11k-firmware/Makefile` 中的:
  - PKG_SOURCE_DATE (更新日期)
  - PKG_SOURCE_VERSION (提交哈希)
  - PKG_MIRROR_HASH (固件哈希)
- 自动提交并推送更改

**Issue 标签**: `ath11k-firmware`

### 3. NSS 补丁同步工作流 (sync-nss-patches.yml)

**运行时间**: 每天凌晨 6:00 (UTC)  
**手动触发**: 支持

**功能**:
- 跟踪 `qosmio/openwrt-ipq` 的 `main-nss` 分支
- 检测 mac80211 和 NSS 相关补丁的更新
- 分析变化类型:
  - mac80211 补丁变化
  - NSS 包配置变化
  - qualcommax 目标相关变化
- 同步更新的补丁
- 自动触发构建验证工作流
- 对于重大变化（如 mac80211 更新），创建 Issue 通知维护者

**Issue 标签**: `nss-patches`, `build-failure`

### 4. 构建验证工作流 (build-verify.yml)

**运行时间**: 仅手动触发或被其他工作流触发  
**手动触发**: 支持

**功能**:
- 释放 GitHub Runner 磁盘空间（删除不需要的软件）
- 设置构建环境
- 使用仓库中的 `.config` 文件（针对 qualcommax/ipq60xx glinet_gl-axt1800）
- 清理旧的内核构建产物
- 编译验证:
  - 工具链
  - Linux 内核
  - mac80211 驱动
  - NSS 相关包
- 构建失败时:
  - 参考 `qosmio/openwrt-ipq` main-nss 分支寻找解决方案
  - 创建 Issue 通知维护者
- 上传构建日志和摘要

**Issue 标签**: `build-failure`, `nss-patches`

## 重要约束

1. **永不删除 NSS 转发功能**: 所有工作流都设计为保护现有的 NSS 转发相关功能
2. **永不自动合并 ath11k-firmware**: 该 Makefile 从单独的仓库跟踪，不接受上游 openwrt/openwrt 的更改
3. **始终保护 GL-AXT1800 支持**: 所有涉及设备支持的更改都会验证 GL-AXT1800 不受影响
4. **自动化 + 人工审查**: 关键更改会创建 Issue 通知维护者进行人工审查

## 手动触发工作流

所有工作流都支持手动触发。在 GitHub 仓库页面:

1. 转到 "Actions" 标签
2. 选择要运行的工作流
3. 点击 "Run workflow" 按钮
4. 选择分支（通常是 main）
5. 点击 "Run workflow" 确认

## 工作流依赖

```
sync-upstream.yml (每天 4:00)
    ↓
    可能触发内核更新
    
sync-ath11k-firmware.yml (每天 5:00)
    ↓
    独立运行
    
sync-nss-patches.yml (每天 6:00)
    ↓
    自动触发 ↓
    
build-verify.yml (按需)
    ↓
    验证构建
```

## 故障排查

### 工作流失败
- 检查工作流日志获取详细错误信息
- 查看自动创建的 Issue（如果有）
- 参考 `qosmio/openwrt-ipq` main-nss 分支

### 上游同步冲突
- 检查 Issue 中的冲突文件列表
- 手动解决冲突并推送
- 确保 GL-AXT1800 支持未被破坏

### 构建失败
- 查看构建日志
- 检查是否是内核版本变化导致
- 对比 `qosmio/openwrt-ipq` main-nss 分支的配置
- 可能需要更新 NSS 补丁或配置

## 权限要求

工作流需要以下权限:
- `contents: write` - 用于推送更改
- `issues: write` - 用于创建 Issue
- `actions: write` - 用于触发其他工作流（NSS 补丁同步触发构建验证）

这些权限已在工作流文件中配置。

## 维护建议

1. 定期检查自动创建的 Issue
2. 重大内核更新时，手动运行构建验证
3. 新设备支持添加时，验证 GL-AXT1800 仍然正常工作
4. NSS 补丁更新后，进行完整的功能测试

## 许可证

这些工作流遵循仓库的主许可证。
