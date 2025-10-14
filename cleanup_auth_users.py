#!/usr/bin/env python3
"""
🔧 Supabase Auth 孤儿用户清理脚本
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

功能：
• 自动删除 Supabase Auth 中的孤儿用户
• 孤儿用户 = Auth 中存在但 users 表中不存在的用户

使用方法：
1. 安装依赖: pip install requests
2. 获取 Service Role Key (Supabase Dashboard → Settings → API)
3. 运行脚本: python cleanup_auth_users.py
"""

import requests
import sys
from typing import List, Dict, Optional

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🔧 配置区域
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SUPABASE_URL = "https://qnwtqgdbgyqwpsdqvxfl.supabase.co"

# ⚠️ 请在这里填入你的 Service Role Key
# 获取位置：Supabase Dashboard → Settings → API → service_role (secret)
SERVICE_ROLE_KEY = ""  # 👈 请填写你的 Service Role Key

# 需要删除的邮箱列表（这些是孤儿用户）
EMAILS_TO_DELETE = [
    "1042338586@qq.com",           # Bella Zhao
    "18274802471@163.com",         # yan yun
    "owenchen1839@gmail.com",      # owenchen1839
    "976318872@qq.com",            # yangmeng
    "mengyang19960220@vip.qq.com", # JoyMeng
    "mengyang1990220@gmail.com",   # Chuiqiang Meng
    "admin@joybilliards.local"     # Admin User
]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🔧 函数定义
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def validate_config() -> bool:
    """验证配置是否正确"""
    if not SERVICE_ROLE_KEY:
        print("❌ 错误：SERVICE_ROLE_KEY 未配置！")
        print("")
        print("请按照以下步骤获取 Service Role Key：")
        print("1. 打开 https://supabase.com/dashboard")
        print("2. 选择你的项目")
        print("3. 进入 Settings → API")
        print("4. 找到 'service_role' (secret) 并复制")
        print("5. 粘贴到本脚本的 SERVICE_ROLE_KEY 变量中")
        print("")
        return False
    
    if len(SERVICE_ROLE_KEY) < 20:
        print("❌ 错误：SERVICE_ROLE_KEY 看起来不正确（太短）")
        return False
    
    return True


def get_headers() -> Dict[str, str]:
    """获取 API 请求头"""
    return {
        "apikey": SERVICE_ROLE_KEY,
        "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
        "Content-Type": "application/json"
    }


def get_user_by_email(email: str) -> Optional[Dict]:
    """
    通过邮箱查询 Auth 用户
    
    返回用户信息或 None（如果用户不存在）
    """
    try:
        response = requests.get(
            f"{SUPABASE_URL}/auth/v1/admin/users",
            headers=get_headers(),
            timeout=10
        )
        
        if response.status_code != 200:
            print(f"⚠️ API 错误 ({response.status_code}): {response.text}")
            return None
        
        users = response.json().get('users', [])
        
        # 查找匹配的用户
        for user in users:
            if user.get('email', '').lower() == email.lower():
                return user
        
        return None
        
    except requests.exceptions.RequestException as e:
        print(f"❌ 网络错误: {e}")
        return None


def delete_user(user_id: str, email: str) -> bool:
    """
    删除 Auth 用户
    
    返回 True 表示成功，False 表示失败
    """
    try:
        response = requests.delete(
            f"{SUPABASE_URL}/auth/v1/admin/users/{user_id}",
            headers=get_headers(),
            timeout=10
        )
        
        if response.status_code == 200:
            return True
        else:
            print(f"❌ 删除失败 ({response.status_code}): {response.text}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"❌ 网络错误: {e}")
        return False


def cleanup_orphaned_users(emails: List[str]) -> Dict[str, int]:
    """
    批量清理孤儿用户
    
    返回统计信息
    """
    stats = {
        "total": len(emails),
        "deleted": 0,
        "not_found": 0,
        "failed": 0
    }
    
    print(f"🔍 开始清理 {stats['total']} 个孤儿用户...\n")
    
    for i, email in enumerate(emails, 1):
        print(f"[{i}/{stats['total']}] 处理: {email}")
        
        # 查询用户
        user = get_user_by_email(email)
        
        if user is None:
            print(f"   ℹ️  用户不存在（可能已被删除）\n")
            stats['not_found'] += 1
            continue
        
        user_id = user.get('id')
        user_created = user.get('created_at', 'Unknown')
        
        print(f"   📋 找到用户:")
        print(f"      ID: {user_id}")
        print(f"      创建时间: {user_created}")
        
        # 删除用户
        print(f"   🗑️  正在删除...")
        if delete_user(user_id, email):
            print(f"   ✅ 删除成功!\n")
            stats['deleted'] += 1
        else:
            print(f"   ❌ 删除失败\n")
            stats['failed'] += 1
    
    return stats


def print_summary(stats: Dict[str, int]):
    """打印清理结果汇总"""
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("📊 清理结果汇总")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print(f"总计:       {stats['total']} 个邮箱")
    print(f"✅ 成功删除: {stats['deleted']} 个")
    print(f"ℹ️  未找到:   {stats['not_found']} 个")
    print(f"❌ 删除失败: {stats['failed']} 个")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    
    if stats['deleted'] > 0:
        print("\n🎉 现在这些邮箱可以重新注册了！")
    
    if stats['failed'] > 0:
        print("\n⚠️ 部分用户删除失败，请检查:")
        print("   • Service Role Key 是否正确")
        print("   • 网络连接是否正常")
        print("   • Supabase 项目是否可访问")


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🚀 主程序
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def main():
    """主程序入口"""
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("🔧 Supabase Auth 孤儿用户清理脚本")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    
    # 验证配置
    if not validate_config():
        sys.exit(1)
    
    print(f"📡 Supabase URL: {SUPABASE_URL}")
    print(f"🔑 Service Role Key: {SERVICE_ROLE_KEY[:10]}...{SERVICE_ROLE_KEY[-10:]}")
    print(f"📋 待清理邮箱数量: {len(EMAILS_TO_DELETE)}\n")
    
    # 确认操作
    print("⚠️ 警告：此操作将永久删除 Auth 中的用户记录！")
    print("")
    print("待删除的邮箱列表：")
    for i, email in enumerate(EMAILS_TO_DELETE, 1):
        print(f"   {i}. {email}")
    print("")
    
    confirm = input("确认要继续吗？(输入 'YES' 确认): ")
    
    if confirm.strip().upper() != "YES":
        print("\n❌ 操作已取消")
        sys.exit(0)
    
    print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    
    # 执行清理
    stats = cleanup_orphaned_users(EMAILS_TO_DELETE)
    
    # 打印结果
    print_summary(stats)
    
    # 返回适当的退出码
    if stats['failed'] > 0:
        sys.exit(1)
    else:
        sys.exit(0)


if __name__ == "__main__":
    main()

