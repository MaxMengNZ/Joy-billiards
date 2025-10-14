# 💳 Joy Billiards Membership Card System

## 🎯 Overview

Joy Billiards now features a comprehensive 3-tier membership card system with exclusive benefits and rewards.

---

## 🏅 Membership Levels

### 🥉 Bronze Member (Default)

**Benefits:**
- ✅ 5% discount on hourly rates
- ✅ Priority table booking
- ✅ Free tournament registration
- ✅ Earn 1 point per $10 spent
- ✅ Member-only events access

**How to Get:**
- Automatic upon registration
- All new users start as Bronze members

**Card Color:** Bronze gradient (Brown/Gold)

---

### 🥈 Silver Member

**Benefits:**
- ✅ 10% discount on hourly rates
- ✅ Priority table booking
- ✅ Free tournament registration
- ✅ Earn 2 points per $10 spent
- ✅ Free equipment rental (cues, chalk)
- ✅ Monthly free hour of play
- ✅ Member-only events access
- ✅ Birthday bonus: 100 points

**How to Get:**
- Spend $500+ in total
- Or earn 500 membership points
- Or admin upgrade

**Card Color:** Silver gradient

---

### 🥇 Gold Member (Premium)

**Benefits:**
- ✅ 20% discount on hourly rates
- ✅ VIP table booking (reserved tables)
- ✅ Free tournament registration
- ✅ Earn 3 points per $10 spent
- ✅ Free equipment rental (premium cues)
- ✅ Weekly free hour of play
- ✅ Guest pass (bring a friend free once per week)
- ✅ Exclusive VIP tournaments access
- ✅ Private coaching session discount (50% off)
- ✅ Birthday bonus: 300 points
- ✅ Anniversary bonus: 500 points

**How to Get:**
- Spend $1,500+ in total
- Or earn 1,500 membership points
- Or admin upgrade

**Card Color:** Gold gradient

---

## 💳 Membership Card Features

### Card Number Format
```
JB-YYYY-XXXXXX

JB = Joy Billiards
YYYY = Year of registration
XXXXXX = Unique 6-digit number
```

**Example:** `JB-2025-574646`

### Card Information
- Member name
- Card number
- Membership level
- Points balance
- Valid until date
- Join date

---

## ⭐ Points System

### Earning Points

| Activity | Points |
|----------|--------|
| $10 spent (Bronze) | 1 point |
| $10 spent (Silver) | 2 points |
| $10 spent (Gold) | 3 points |
| Tournament win | 50 points |
| Tournament participation | 10 points |
| Refer a friend | 100 points |

### Redeeming Points

| Reward | Points Cost |
|--------|-------------|
| 1 hour free play | 100 points |
| Tournament entry (premium) | 200 points |
| Equipment upgrade | 300 points |
| Private coaching hour | 500 points |
| Birthday party package | 1,000 points |

---

## 🔄 Upgrade Path

```
Bronze (Default)
    ↓ Spend $500 or 500 points
Silver
    ↓ Spend $1,500 or 1,500 points  
Gold
```

---

## 📊 Max Meng's Current Status

```
Name: Max Meng
Email: maxmengnz@qq.com
Card Number: JB-2025-574646
Level: 🥇 Gold Member
Points: 0
Role: 👑 Administrator
Valid Until: Oct 2026
```

---

## 🎯 How to Access Your Profile

### For Logged-in Users:

1. **Click your name** in the top navigation bar
   - Shows as "👤 Your Name"
   - Click it to go to profile page

2. **Or visit directly:**
   ```
   http://localhost:3000/profile
   ```

### Profile Page Features:

✅ **Membership Card Display**
- Beautiful card with your level color
- Shows card number, name, points
- Benefits list based on your level

✅ **Personal Information**
- Edit your name, phone, skill level
- View your email (cannot change)
- Update profile button

✅ **Statistics**
- Wins and losses
- Win rate percentage
- Membership points
- Current skill level

✅ **Account Settings**
- View your role (Admin/Player)
- Account status
- Change password option

---

## 🎨 Membership Card Design

### Bronze Card
- Color: Bronze gradient (#cd7f32 → #8b5a2b)
- Icon: 🥉
- Theme: Warm brown tones

### Silver Card
- Color: Silver gradient (#c0c0c0 → #808080)
- Icon: 🥈
- Theme: Metallic silver

### Gold Card
- Color: Gold gradient (#ffd700 → #daa520)
- Icon: 🥇
- Theme: Luxury gold

---

## 🔧 Admin Functions

### Upgrade Member Level (SQL)

```sql
-- Upgrade to Silver
UPDATE users 
SET membership_level = 'silver' 
WHERE email = 'user@example.com';

-- Upgrade to Gold
UPDATE users 
SET membership_level = 'gold' 
WHERE email = 'user@example.com';

-- Add points
UPDATE users 
SET membership_points = membership_points + 100 
WHERE email = 'user@example.com';
```

### View All Members

```sql
SELECT 
    name,
    email,
    membership_card_number,
    membership_level,
    membership_points
FROM users
ORDER BY membership_level DESC, membership_points DESC;
```

---

## 📱 Responsive Design

The membership card and profile page are fully responsive:
- **Desktop:** Full card display with all details
- **Tablet:** Adjusted layout
- **Mobile:** Stacked sections, touch-optimized

---

## 🧪 Test Your Profile

### Step 1: Visit Profile Page

Click your name "👤 Max Meng 👑" in the navigation

Or visit: http://localhost:3000/profile

### Step 2: View Your Membership Card

You should see:
- ✅ Beautiful gold gradient card
- ✅ Your card number: JB-2025-574646
- ✅ Gold Member badge
- ✅ All premium benefits listed

### Step 3: Edit Personal Information

1. Click "Edit" button
2. Update your phone number or skill level
3. Click "Save Changes"
4. Profile updates successfully!

### Step 4: Check Statistics

View your:
- Wins: 0
- Losses: 0
- Win Rate: 0%
- Points: 0

(These will update as you play matches!)

---

## 🎁 Future Enhancements

### Planned Features:
- [ ] QR code on membership card
- [ ] Digital wallet integration
- [ ] Points redemption interface
- [ ] Automatic level upgrades
- [ ] Purchase history
- [ ] Point transaction log
- [ ] Referral system
- [ ] Birthday reminders
- [ ] Membership renewal notifications

---

## 📞 Membership Support

For membership inquiries:
- 📍 88 Tristram Street, Hamilton Central
- 📞 022 166 0688
- 💬 Ask staff at the venue

---

## ✅ System Status

```
✅ Membership cards auto-generated
✅ 3-tier level system active
✅ Points system configured
✅ Profile page created
✅ Editable personal info
✅ Beautiful card design
✅ Responsive layout
✅ Max Meng: Gold Member 🥇

Status: Ready to Use!
```

---

**Your membership card is ready!** 💳✨

*Click your name to view your profile and membership card!*

