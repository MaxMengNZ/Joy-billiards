<template>
  <div class="membership-page">
    <!-- Hero Section with Dynamic Background -->
    <section class="membership-hero">
      <div class="membership-hero-background">
        <div class="membership-hero-pattern"></div>
        <div class="membership-hero-glow membership-hero-glow-left"></div>
        <div class="membership-hero-glow membership-hero-glow-right"></div>
      </div>
      <div class="membership-hero-content">
        <div class="hero-badge">
          <span class="badge-icon">💳</span>
          <span class="badge-text">Exclusive Membership System</span>
        </div>
        <h1 class="hero-title">
          Join <span class="title-highlight">Joy Billiards</span> Membership
        </h1>
        <p class="hero-subtitle">
          Choose your level, unlock exclusive benefits, and elevate your billiards experience
        </p>
        <div class="hero-stats">
          <div class="hero-stat-item">
            <div class="hero-stat-number">4</div>
            <div class="hero-stat-label">Membership Tiers</div>
          </div>
          <div class="hero-stat-item">
            <div class="hero-stat-number">$10.7</div>
            <div class="hero-stat-label">Max Savings/Hour</div>
          </div>
          <div class="hero-stat-item">
            <div class="hero-stat-number">1.6x</div>
            <div class="hero-stat-label">Max Points Multiplier</div>
          </div>
        </div>
      </div>
    </section>

    <div class="membership-content">

    <!-- Membership Tiers -->
    <section class="tiers-section">
      <h2 class="section-title">Choose Your Membership Level</h2>
      <div class="tiers-grid">
        <!-- Lite -->
        <div class="tier-card tier-lite">
          <div class="tier-header">
            <div class="tier-icon">🎱</div>
            <h3 class="tier-name">Lite</h3>
            <p class="tier-tagline">Perfect for Casual Players</p>
          </div>
          <div class="tier-price">
            <span class="price-amount">FREE</span>
            <span class="price-period">Forever</span>
          </div>
          <ul class="tier-features">
            <li><span class="feature-icon">✅</span> Free registration</li>
            <li><span class="feature-icon">🎱</span> Q7: $28/h | Q8: $33/h</li>
            <li><span class="feature-icon">🎯</span> Basic cue sticks</li>
            <li><span class="feature-icon">📊</span> Basic statistics</li>
            <li><span class="feature-icon">📅</span> Same-day booking (2h advance)</li>
            <li><span class="feature-icon">💰</span> Loyalty Points: 1.0x</li>
          </ul>
          <div class="lite-note">All prices include GST</div>
          <button class="btn btn-secondary btn-lg" @click="scrollToSignup">Join Free</button>
        </div>

        <!-- Plus -->
        <div class="tier-card tier-plus">
          <div class="tier-header">
            <div class="tier-icon">⭐</div>
            <h3 class="tier-name">Plus</h3>
            <p class="tier-tagline">Great Value for Regular Players</p>
          </div>
          <div class="tier-price">
            <span class="price-amount">$200+</span>
            <span class="price-period">Get $210 credit (+5% bonus)</span>
          </div>
          <ul class="tier-features">
            <li><span class="feature-icon">💰</span> Q7: $23.8/h | Q8: $28.6/h</li>
            <li><span class="feature-icon">🎁</span> +5% bonus = $210 credit</li>
            <li><span class="feature-icon">⭐</span> Loyalty Points: 1.2x faster</li>
            <li><span class="feature-icon">🎯</span> Premium cue sticks</li>
            <li><span class="feature-icon">📅</span> 6h priority booking</li>
            <li><span class="feature-icon">🕐</span> Use anytime (opening hours)</li>
          </ul>
          <div class="savings-badge">Save $408/year (2h/week) | $4.2/hour</div>
          <button class="btn btn-primary btn-lg" @click="contactUs">Upgrade Now</button>
        </div>

        <!-- Pro -->
        <div class="tier-card tier-pro recommended">
          <div class="recommended-badge">⭐ POPULAR</div>
          <div class="tier-header">
            <div class="tier-icon">💎</div>
            <h3 class="tier-name">Pro</h3>
            <p class="tier-tagline">Best for Serious Players</p>
          </div>
          <div class="tier-price">
            <span class="price-amount">$500+</span>
            <span class="price-period">Get $540 credit (+8% bonus)</span>
          </div>
          <ul class="tier-features">
            <li><span class="feature-icon">💰</span> Q7: $19.5/h | Q8: $24.1/h</li>
            <li><span class="feature-icon">🎁</span> +8% bonus = $540 credit</li>
            <li><span class="feature-icon">⭐</span> Loyalty Points: 1.4x faster</li>
            <li><span class="feature-icon">🎯</span> Premium cue sticks</li>
            <li><span class="feature-icon">📅</span> 12h priority booking</li>
            <li><span class="feature-icon">🎖️</span> Tournament priority</li>
          </ul>
          <div class="savings-badge">Save $4,080/year (10h/week) | $8.5/hour</div>
          <button class="btn btn-success btn-lg" @click="contactUs">Upgrade Now</button>
        </div>

        <!-- Pro Max -->
        <div class="tier-card tier-pro-max vip">
          <div class="vip-badge">👑 LIMITED SEATS</div>
          <div class="tier-header">
            <div class="tier-icon">🌟</div>
            <h3 class="tier-name">Pro Max</h3>
            <p class="tier-tagline">Ultimate VIP Experience</p>
          </div>
          <div class="tier-price">
            <span class="price-amount">$1000+</span>
            <span class="price-period">Get $1100 credit (+10% bonus)</span>
          </div>
          <ul class="tier-features">
            <li><span class="feature-icon">💰</span> Q7: $17.3/h | Q8: $21.8/h</li>
            <li><span class="feature-icon">🎁</span> +10% bonus = $1100 credit</li>
            <li><span class="feature-icon">⭐</span> Loyalty Points: 1.6x fastest</li>
            <li><span class="feature-icon">🎯</span> Premium cue sticks</li>
            <li><span class="feature-icon">📅</span> 24h VIP priority booking</li>
            <li><span class="feature-icon">🎂</span> Birthday gift (exclusive)</li>
          </ul>
          <div class="savings-badge premium">Save $5,136/year (10h/week) | ⚠️ Limited Slots</div>
          <button class="btn btn-warning btn-lg" @click="contactUs">Apply for VIP</button>
        </div>
      </div>
    </section>

    <!-- Comparison Table -->
    <section class="comparison-section">
      <h2 class="section-title">Feature Comparison</h2>
      <div class="table-container">
        <table class="comparison-table">
          <thead>
            <tr>
              <th class="feature-column">Features</th>
              <th class="tier-column lite">🎱 Lite</th>
              <th class="tier-column plus">⭐ Plus</th>
              <th class="tier-column pro">💎 Pro</th>
              <th class="tier-column pro-max">🌟 Pro Max</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td class="feature-name">Entry Requirement</td>
              <td>Free</td>
              <td>≥ $200</td>
              <td>≥ $500</td>
              <td class="best">≥ $1000</td>
            </tr>
            <tr>
              <td class="feature-name">Credit After Bonus</td>
              <td>-</td>
              <td>$210</td>
              <td>$540</td>
              <td class="best">$1100</td>
            </tr>
            <tr>
              <td class="feature-name">Q7 Rate (with bonus)</td>
              <td>$28/hour</td>
              <td class="highlight">$23.8/hour</td>
              <td class="highlight">$19.5/hour</td>
              <td class="highlight best">$17.3/hour</td>
            </tr>
            <tr>
              <td class="feature-name">Q8 Rate (with bonus)</td>
              <td>$33/hour</td>
              <td class="highlight">$28.6/hour</td>
              <td class="highlight">$24.1/hour</td>
              <td class="highlight best">$21.8/hour</td>
            </tr>
            <tr>
              <td class="feature-name">Priority Booking</td>
              <td>Same-day 2h</td>
              <td>6h advance</td>
              <td class="highlight">12h advance</td>
              <td class="best">24h VIP</td>
            </tr>
            <tr>
              <td class="feature-name">Equipment</td>
              <td>Basic cues</td>
              <td>Premium cues</td>
              <td>Premium cues</td>
              <td class="best">Premium cues</td>
            </tr>
            <tr>
              <td class="feature-name">Loyalty Points</td>
              <td>1.0x</td>
              <td>1.2x</td>
              <td>1.4x</td>
              <td class="best">1.6x</td>
            </tr>
            <tr>
              <td class="feature-name">Birthday Gift</td>
              <td>-</td>
              <td>-</td>
              <td>-</td>
              <td class="best">✅ Exclusive</td>
            </tr>
            <tr>
              <td class="feature-name">Availability</td>
              <td>Unlimited</td>
              <td>Unlimited</td>
              <td>Unlimited</td>
              <td class="best">⚠️ Limited Slots</td>
            </tr>
            <tr>
              <td class="feature-name">Account Validity</td>
              <td>Permanent</td>
              <td>12 months</td>
              <td>12 months</td>
              <td>12 months</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>

    <!-- How It Works -->
    <section class="how-it-works-section">
      <h2 class="section-title">How It Works</h2>
      <div class="steps-grid">
        <div class="step-card">
          <div class="step-number">1</div>
          <div class="step-icon">📝</div>
          <h3>Register</h3>
          <p>Create your free Lite account and get your membership card number instantly</p>
        </div>
        <div class="step-card">
          <div class="step-number">2</div>
          <div class="step-icon">💳</div>
          <h3>Recharge</h3>
          <p>Add credit to your account (≥$200 for Plus, ≥$500 for Pro, ≥$1000 for Pro Max)</p>
        </div>
        <div class="step-card">
          <div class="step-number">3</div>
          <div class="step-icon">🎱</div>
          <h3>Play & Save</h3>
          <p>Enjoy discounted rates and exclusive benefits every time you play</p>
        </div>
        <div class="step-card">
          <div class="step-number">4</div>
          <div class="step-icon">⭐</div>
          <h3>Earn Points</h3>
          <p>Earn loyalty points with multipliers (Lite 1.0x → Pro Max 1.6x) and redeem for rewards</p>
        </div>
      </div>
    </section>

    <!-- Benefits Details -->
    <section class="benefits-section">
      <h2 class="section-title">Membership Benefits Details</h2>
      <div class="benefits-grid">
        <div class="benefit-card">
          <div class="benefit-icon">💰</div>
          <h3>Save Big Anytime</h3>
          <p>Save up to $10.7/hour! Pro Max members save $5,136 per year (10h/week). Member rates apply anytime during opening hours - evenings and weekends included!</p>
        </div>
        <div class="benefit-card">
          <div class="benefit-icon">🎁</div>
          <h3>Instant Bonus Credit</h3>
          <p>Get free credit instantly! Recharge $1000 → Get $1100 (+10%). Your bonus credit works just like cash - use it anytime!</p>
        </div>
        <div class="benefit-card">
          <div class="benefit-icon">📅</div>
          <h3>Book 24h in Advance</h3>
          <p>Pro Max VIP members can book up to 24 hours ahead with highest priority. Pro: 12h. Plus: 6h. Secure your favorite table!</p>
        </div>
        <div class="benefit-card">
          <div class="benefit-icon">👑</div>
          <h3>Pro Max Limited Slots</h3>
          <p>Exclusive VIP membership with strictly limited availability! Enjoy 24h priority booking, 1.6x points, and birthday gifts. Apply before slots fill up!</p>
        </div>
        <div class="benefit-card">
          <div class="benefit-icon">🎂</div>
          <h3>Birthday Surprises</h3>
          <p>Pro Max members receive exclusive birthday gifts - premium drinks or Joy Billiards merchandise. Celebrate your special day with us!</p>
        </div>
        <div class="benefit-card">
          <div class="benefit-icon">😊</div>
          <h3>First Mistake Forgiven</h3>
          <p>First time no-show or late cancellation? We've got you covered! No fees for your first mistake (once per 12 months). We understand life happens!</p>
        </div>
      </div>
    </section>

    <!-- Important Notes -->
    <section class="notes-section">
      <div class="notes-card">
        <h2 class="card-title">💡 Important Information</h2>
        <div class="notes-content">
          <div class="note-item">
            <span class="note-icon">✨</span>
            <div class="note-text">
              <strong>Member Rates Anytime:</strong> Discounted member rates (Q7: $23.8/$19.5/$17.3, Q8: $28.6/$24.1/$21.8) apply anytime during opening hours. No time restrictions!
            </div>
          </div>
          <div class="note-item">
            <span class="note-icon">🕐</span>
            <div class="note-text">
              <strong>Free Hours Restriction:</strong> Free hours (gifted or redeemed with points) ONLY valid Mon-Fri 9AM-5PM. Not valid on evenings, weekends, public holidays, or tournament days.
            </div>
          </div>
          <div class="note-item">
            <span class="note-icon">📅</span>
            <div class="note-text">
              <strong>Booking & Cancellation:</strong> Plus: No deposit. Pro/Pro Max: 1-hour pre-authorization. Cancel <3h = 50% fee. No-show = 100% fee. First violation forgiven.
            </div>
          </div>
          <div class="note-item">
            <span class="note-icon">👑</span>
            <div class="note-text">
              <strong>Pro Max Limited Slots:</strong> Pro Max membership has strictly limited availability to ensure VIP service quality. A waitlist will be applied once slots are full. Secure your VIP status early!
            </div>
          </div>
          <div class="note-item">
            <span class="note-icon">❌</span>
            <div class="note-text">
              <strong>Non-Refundable & Non-Transferable:</strong> Balance cannot be refunded or transferred. Points valid for 12 months. No stacking with other promotions.
            </div>
          </div>
          <div class="note-item">
            <span class="note-icon">📉</span>
            <div class="note-text">
              <strong>Auto Tier Adjustment:</strong> Renewal amount determines your tier. Recharge <$500 as Pro → auto-downgrade to Plus. Changes take effect instantly!
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Additional Benefits -->
    <section class="additional-benefits-section">
      <h2 class="section-title">Additional Member Benefits</h2>
      <div class="row">
        <div class="col col-2">
          <div class="benefit-detail-card">
            <div class="benefit-detail-icon">⭐</div>
            <h3>Loyalty Points System</h3>
            <p class="benefit-description">Earn points with multipliers (1.0x - 1.6x)</p>
            <ul class="benefit-list">
              <li>Lite: 1.0x | Plus: 1.2x | Pro: 1.4x | Pro Max: 1.6x</li>
              <li>Redeem for off-peak play vouchers (Mon-Fri 9AM-5PM)</li>
              <li>Exchange for beverages and snacks</li>
              <li>Get equipment accessories</li>
              <li>12-month rolling validity</li>
            </ul>
          </div>
        </div>
        <div class="col col-2">
          <div class="benefit-detail-card">
            <div class="benefit-detail-icon">🎉</div>
            <h3>Member Events</h3>
            <p class="benefit-description">Exclusive events for our community</p>
            <ul class="benefit-list">
              <li>Monthly member tournaments</li>
              <li>Quarterly VIP championships</li>
              <li>Member-only social nights</li>
              <li>Special discount days</li>
            </ul>
          </div>
        </div>
      </div>
    </section>

    <!-- Pricing Examples -->
    <section class="pricing-examples-section">
      <h2 class="section-title">Pricing Examples</h2>
      <div class="examples-grid">
        <div class="example-card">
          <h3>🎱 Casual Player (2h/week, Q7)</h3>
          <div class="example-calc">
            <div class="calc-row">
              <span>Lite Member:</span>
              <span class="price">$28 × 2h × 4 = <strong>$224/month</strong></span>
            </div>
            <div class="calc-row highlight">
              <span>Plus Member:</span>
              <span class="price">$23.8 × 2h × 4 = <strong>$190/month</strong></span>
            </div>
            <div class="savings">💰 Save $34/month = $408/year</div>
          </div>
        </div>
        <div class="example-card">
          <h3>🏆 Regular Player (10h/week, Q7)</h3>
          <div class="example-calc">
            <div class="calc-row">
              <span>Lite Member:</span>
              <span class="price">$28 × 10h × 4 = <strong>$1,120/month</strong></span>
            </div>
            <div class="calc-row highlight">
              <span>Pro Member:</span>
              <span class="price">$19.5 × 10h × 4 = <strong>$780/month</strong></span>
            </div>
            <div class="savings">💰 Save $340/month = $4,080/year</div>
          </div>
        </div>
        <div class="example-card">
          <h3>💎 Enthusiast (10h/week, Q7)</h3>
          <div class="example-calc">
            <div class="calc-row">
              <span>Lite Member:</span>
              <span class="price">$28 × 10h × 4 = <strong>$1,120/month</strong></span>
            </div>
            <div class="calc-row highlight best">
              <span>Pro Max Member:</span>
              <span class="price">$17.3 × 10h × 4 = <strong>$692/month</strong></span>
            </div>
            <div class="savings premium">💎 Save $428/month = $5,136/year + VIP Perks</div>
          </div>
        </div>
      </div>
    </section>

    <!-- FAQ Section -->
    <section class="faq-section">
      <h2 class="section-title">Frequently Asked Questions</h2>
      <div class="faq-grid">
        <div class="faq-item">
          <h3 class="faq-question">💰 Can I use my member rates on weekends?</h3>
          <p class="faq-answer">YES! Member discounted rates apply anytime - evenings, weekends, and holidays included! Only free hours vouchers are restricted to Mon-Fri 9AM-5PM.</p>
        </div>
        <div class="faq-item">
          <h3 class="faq-question">👑 How limited is Pro Max membership?</h3>
          <p class="faq-answer">Pro Max has strictly limited slots to ensure VIP service quality. Once full, a waitlist applies. Secure your spot early for 24h booking, 1.6x points, and birthday gifts!</p>
        </div>
        <div class="faq-item">
          <h3 class="faq-question">🎁 What if I miss my booking?</h3>
          <p class="faq-answer">First time forgiven! Your first no-show or late cancellation (within 12 months) is fee-free. We understand life happens. From the second time, standard fees apply.</p>
        </div>
        <div class="faq-item">
          <h3 class="faq-question">📅 How far in advance can I book?</h3>
          <p class="faq-answer">Lite: Same-day (2h) | Plus: 6h advance | Pro: 12h advance | Pro Max: 24h VIP priority. Higher tiers = better table availability!</p>
        </div>
        <div class="faq-item">
          <h3 class="faq-question">⭐ How fast do I earn points?</h3>
          <p class="faq-answer">Lite: 1.0x | Plus: 1.2x | Pro: 1.4x | Pro Max: 1.6x. Example: Spend $100 → Pro Max earns 160 points vs Lite's 100 points! Redeem for play vouchers or drinks.</p>
        </div>
        <div class="faq-item">
          <h3 class="faq-question">🎂 Do Pro Max members get birthday perks?</h3>
          <p class="faq-answer">Yes! Pro Max members receive exclusive birthday gifts during their birthday month - premium drinks or Joy Billiards merchandise. It's our way of celebrating you!</p>
        </div>
      </div>
    </section>

    <!-- Call to Action -->
    <section class="cta-section">
      <div class="cta-content">
        <h2>Ready to Join Joy Billiards?</h2>
        <p>Start with a free Lite membership or upgrade to unlock exclusive benefits!</p>
        <div class="cta-info">
          <p class="cta-contact">
            📍 88 Tristram Street, Hamilton Central<br>
            📞 022 166 0688 | 📧 info@joybilliards.co.nz
          </p>
          <p class="cta-hours">
            ⏰ Mon-Thu: 9AM-1AM | Fri-Sat: 9AM-2AM | Sun: 10AM-1AM
          </p>
        </div>
        <div class="cta-buttons">
          <router-link to="/register" class="btn btn-primary btn-lg">
            🎱 Join Free Now
          </router-link>
          <button class="btn btn-warning btn-lg" @click="contactUs">
            📞 Call Us Now
          </button>
        </div>
      </div>
    </section>
    </div>
  </div>
</template>

<script>
export default {
  name: 'MembershipPage',
  setup() {
    const scrollToSignup = () => {
      window.scrollTo({ top: document.body.scrollHeight, behavior: 'smooth' })
    }

    const contactUs = () => {
      window.location.href = 'tel:0221660688'
    }

    return {
      scrollToSignup,
      contactUs
    }
  }
}
</script>

<style scoped>
.membership-page {
  max-width: 100%;
  margin: 0;
  padding: 0;
}

/* Membership Hero Section */
.membership-hero {
  position: relative;
  padding: 6rem 2rem 5rem;
  overflow: hidden;
  text-align: center;
  margin-bottom: 3rem;
}

.membership-hero-background {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, #F093FB 0%, #F5576C 25%, #667eea 50%, #F5576C 75%, #F093FB 100%);
  z-index: 0;
}

.membership-hero-pattern {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-image: 
    radial-gradient(circle at 20% 20%, rgba(255, 255, 255, 0.12) 0%, transparent 50%),
    radial-gradient(circle at 80% 80%, rgba(102, 126, 234, 0.12) 0%, transparent 50%),
    radial-gradient(circle at 50% 50%, rgba(255, 215, 0, 0.08) 0%, transparent 50%);
  animation: pattern-drift-membership 26s ease-in-out infinite;
}

@keyframes pattern-drift-membership {
  0%, 100% { transform: translate(0, 0) scale(1); }
  50% { transform: translate(25px, 25px) scale(1.05); }
}

.membership-hero-glow {
  position: absolute;
  width: 700px;
  height: 700px;
  border-radius: 50%;
  filter: blur(100px);
  animation: glow-pulse-membership 6s ease-in-out infinite;
}

.membership-hero-glow-left {
  top: 20%;
  left: 10%;
  background: radial-gradient(circle, rgba(255, 215, 0, 0.3) 0%, transparent 70%);
  animation-delay: 0s;
}

.membership-hero-glow-right {
  top: 60%;
  right: 10%;
  background: radial-gradient(circle, rgba(240, 147, 251, 0.3) 0%, transparent 70%);
  animation-delay: 3s;
}

@keyframes glow-pulse-membership {
  0%, 100% { opacity: 0.5; transform: scale(1); }
  50% { opacity: 0.9; transform: scale(1.15); }
}

.membership-hero-content {
  position: relative;
  z-index: 1;
  max-width: 900px;
  margin: 0 auto;
}

.hero-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.625rem 1.5rem;
  background: rgba(255, 255, 255, 0.25);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.4);
  border-radius: 50px;
  margin-bottom: 1.5rem;
  font-size: 0.875rem;
  font-weight: 600;
  color: white;
  letter-spacing: 0.5px;
  animation: badge-float-membership 3s ease-in-out infinite;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

@keyframes badge-float-membership {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-8px); }
}

.badge-icon {
  font-size: 1.125rem;
}

.hero-title {
  font-size: 3.5rem;
  font-weight: 800;
  color: white;
  margin-bottom: 1rem;
  line-height: 1.2;
  text-shadow: 0 4px 20px rgba(0, 0, 0, 0.4);
  animation: title-fade-in 1s ease-out;
}

@keyframes title-fade-in {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

.title-highlight {
  background: linear-gradient(135deg, #FFD700 0%, #F093FB 50%, #667eea 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  animation: gradient-shift-membership 3s ease-in-out infinite;
  background-size: 200% 200%;
}

@keyframes gradient-shift-membership {
  0%, 100% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
}

.hero-subtitle {
  font-size: 1.25rem;
  color: rgba(255, 255, 255, 0.95);
  font-weight: 500;
  line-height: 1.7;
  margin-bottom: 2rem;
}

.hero-stats {
  display: flex;
  justify-content: center;
  gap: 3rem;
  margin-top: 3rem;
  flex-wrap: wrap;
}

.hero-stat-item {
  text-align: center;
}

.hero-stat-number {
  font-size: 3rem;
  font-weight: 800;
  color: white;
  text-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
  margin-bottom: 0.5rem;
  background: linear-gradient(135deg, #FFD700 0%, #FFFFFF 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.hero-stat-label {
  font-size: 0.875rem;
  color: rgba(255, 255, 255, 0.9);
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.membership-content {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 2rem 3rem;
}

/* Section Title */
.section-title {
  font-size: 2.5rem;
  font-weight: 700;
  text-align: center;
  margin-bottom: 3rem;
  color: #1a1a2e;
}

/* Tiers Section */
.tiers-section {
  padding: 4rem 0;
}

.tiers-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 2rem;
  max-width: 1400px;
  margin: 0 auto;
}

.tier-card {
  background: white;
  border-radius: 24px;
  padding: 2.5rem;
  box-shadow: 0 8px 32px rgba(0,0,0,0.1);
  transition: all 0.4s ease;
  position: relative;
  overflow: hidden;
  border: 3px solid transparent;
}

/* Top stripe */
.tier-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 6px;
  z-index: 2;
}

.tier-card.tier-lite::before { background: linear-gradient(90deg, #a8edea, #fed6e3); }
.tier-card.tier-plus::before { background: linear-gradient(90deg, #f093fb, #f5576c); }
.tier-card.tier-pro::before { background: linear-gradient(90deg, #667eea, #764ba2); }
.tier-card.tier-pro-max::before { background: linear-gradient(90deg, #FF6B6B, #4ECDC4); }

/* Shine effect */
.tier-card::after {
  content: '';
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background: linear-gradient(
    45deg,
    transparent 30%,
    rgba(255, 255, 255, 0.3) 50%,
    transparent 70%
  );
  transform: translateX(-100%) translateY(-100%) rotate(45deg);
  transition: transform 0.6s ease;
  z-index: 1;
}

.tier-card:hover::after {
  transform: translateX(100%) translateY(100%) rotate(45deg);
}

.tier-card:hover {
  transform: translateY(-15px) scale(1.02);
  box-shadow: 0 20px 60px rgba(0,0,0,0.25);
}

.tier-card.recommended {
  border-color: #667eea;
  box-shadow: 0 8px 32px rgba(102, 126, 234, 0.2);
}

.tier-card.recommended:hover {
  box-shadow: 0 20px 60px rgba(102, 126, 234, 0.35);
}

.tier-card.vip {
  border-color: #FF6B6B;
  background: linear-gradient(135deg, #ffffff 0%, #fff5f5 100%);
  box-shadow: 0 8px 32px rgba(255, 107, 107, 0.2);
}

.tier-card.vip:hover {
  box-shadow: 0 20px 60px rgba(255, 107, 107, 0.35);
}

.recommended-badge,
.vip-badge {
  position: absolute;
  top: 1.5rem;
  right: 1.5rem;
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.recommended-badge {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.vip-badge {
  background: linear-gradient(135deg, #FF6B6B, #4ECDC4);
  color: white;
  box-shadow: 0 4px 12px rgba(255, 107, 107, 0.4);
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.05); }
}

.tier-header {
  text-align: center;
  margin-bottom: 2rem;
  position: relative;
  z-index: 2;
}

.tier-icon {
  font-size: 4rem;
  margin-bottom: 1rem;
  transition: transform 0.3s ease;
}

.tier-card:hover .tier-icon {
  transform: scale(1.1) rotate(5deg);
}

.tier-name {
  font-size: 2rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
  color: #1a1a2e;
}

.tier-tagline {
  font-size: 1rem;
  color: #6c757d;
  font-weight: 500;
}

.tier-price {
  text-align: center;
  padding: 1.5rem;
  background: #f8f9fa;
  border-radius: 12px;
  margin-bottom: 2rem;
  position: relative;
  z-index: 2;
}

.price-amount {
  display: block;
  font-size: 2.5rem;
  font-weight: 800;
  color: #667eea;
  margin-bottom: 0.25rem;
}

.price-period {
  font-size: 0.875rem;
  color: #6c757d;
  font-weight: 500;
}

.tier-features {
  list-style: none;
  padding: 0;
  margin: 0 0 2rem 0;
  position: relative;
  z-index: 2;
}

.tier-features li {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem 0;
  font-size: 1rem;
  color: #495057;
  border-bottom: 1px solid #f0f0f0;
}

.tier-features li:last-child {
  border-bottom: none;
}

.feature-icon {
  font-size: 1.25rem;
  flex-shrink: 0;
}

.savings-badge {
  background: linear-gradient(135deg, #28a745, #20c997);
  color: white;
  padding: 0.75rem;
  border-radius: 8px;
  text-align: center;
  font-weight: 700;
  margin-bottom: 1.5rem;
  font-size: 0.875rem;
  position: relative;
  z-index: 2;
}

.savings-badge.premium {
  background: linear-gradient(135deg, #FF6B6B, #4ECDC4);
  font-size: 1rem;
}

.lite-note {
  background: #f8f9fa;
  color: #6c757d;
  padding: 0.5rem;
  border-radius: 6px;
  text-align: center;
  font-size: 0.75rem;
  margin-bottom: 1.5rem;
  font-weight: 600;
  position: relative;
  z-index: 2;
}

.tier-card .btn {
  width: 100%;
  position: relative;
  z-index: 2;
}

/* Comparison Table */
.comparison-section {
  padding: 4rem 0;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  border-radius: 32px;
  margin: 3rem 0;
}

.comparison-table {
  width: 100%;
  background: white;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 8px 32px rgba(0,0,0,0.1);
}

.comparison-table thead {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
}

.comparison-table th {
  padding: 1.5rem;
  font-weight: 700;
  text-align: center;
}

.comparison-table th.feature-column {
  text-align: left;
  min-width: 200px;
}

.comparison-table td {
  padding: 1rem 1.5rem;
  text-align: center;
  border-bottom: 1px solid #e9ecef;
}

.comparison-table td.feature-name {
  font-weight: 600;
  text-align: left;
  color: #1a1a2e;
}

.comparison-table td.highlight {
  background: linear-gradient(135deg, #f0fdf4, #dcfce7);
  font-weight: 700;
  color: #166534;
}

.comparison-table td.best {
  background: linear-gradient(135deg, #fff7ed, #fed7aa);
  font-weight: 800;
  color: #9a3412;
}

.tier-column.lite { background: rgba(168, 237, 234, 0.1); }
.tier-column.plus { background: rgba(240, 147, 251, 0.1); }
.tier-column.pro { background: rgba(102, 126, 234, 0.1); }
.tier-column.pro-max { background: rgba(255, 107, 107, 0.1); }

/* How It Works */
.how-it-works-section {
  padding: 4rem 0;
}

.steps-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}

.step-card {
  background: white;
  padding: 2rem;
  border-radius: 16px;
  box-shadow: 0 4px 16px rgba(0,0,0,0.08);
  text-align: center;
  position: relative;
  transition: transform 0.3s ease;
}

.step-card:hover {
  transform: translateY(-8px);
}

.step-number {
  position: absolute;
  top: -15px;
  left: 50%;
  transform: translateX(-50%);
  width: 40px;
  height: 40px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 1.25rem;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.step-icon {
  font-size: 3rem;
  margin: 1rem 0;
}

.step-card h3 {
  font-size: 1.5rem;
  font-weight: 700;
  margin-bottom: 1rem;
  color: #1a1a2e;
}

.step-card p {
  color: #6c757d;
  line-height: 1.6;
}

/* Benefits Section */
.benefits-section {
  padding: 4rem 0;
}

.benefits-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}

.benefit-card {
  background: white;
  padding: 2rem;
  border-radius: 16px;
  box-shadow: 0 4px 16px rgba(0,0,0,0.08);
  text-align: center;
  transition: all 0.3s ease;
  border-top: 4px solid #667eea;
}

.benefit-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 12px 32px rgba(0,0,0,0.15);
}

.benefit-icon {
  font-size: 3.5rem;
  margin-bottom: 1rem;
}

.benefit-card h3 {
  font-size: 1.5rem;
  font-weight: 700;
  margin-bottom: 1rem;
  color: #1a1a2e;
}

.benefit-card p {
  color: #6c757d;
  line-height: 1.6;
}

/* Notes Section */
.notes-section {
  padding: 4rem 0;
  background: #f8f9fa;
  border-radius: 32px;
  margin: 3rem 0;
}

.notes-card {
  max-width: 1000px;
  margin: 0 auto;
  background: white;
  padding: 3rem;
  border-radius: 24px;
  box-shadow: 0 8px 32px rgba(0,0,0,0.1);
}

.notes-card .card-title {
  font-size: 2rem;
  font-weight: 700;
  margin-bottom: 2rem;
  color: #1a1a2e;
  text-align: center;
}

.notes-content {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.note-item {
  display: flex;
  gap: 1.5rem;
  padding: 1.5rem;
  background: #f8f9fa;
  border-radius: 12px;
  border-left: 4px solid #667eea;
}

.note-icon {
  font-size: 2rem;
  flex-shrink: 0;
}

.note-text {
  flex: 1;
}

.note-text strong {
  color: #1a1a2e;
  display: block;
  margin-bottom: 0.5rem;
  font-size: 1.125rem;
}

.note-text {
  color: #495057;
  line-height: 1.6;
}

/* Additional Benefits */
.additional-benefits-section {
  padding: 4rem 0;
}

.benefit-detail-card {
  background: white;
  padding: 2rem;
  border-radius: 16px;
  box-shadow: 0 4px 16px rgba(0,0,0,0.08);
  height: 100%;
}

.benefit-detail-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.benefit-detail-card h3 {
  font-size: 1.75rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
  color: #1a1a2e;
}

.benefit-description {
  color: #667eea;
  font-weight: 600;
  margin-bottom: 1.5rem;
}

.benefit-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.benefit-list li {
  padding: 0.5rem 0;
  color: #495057;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.benefit-list li::before {
  content: '✅';
  flex-shrink: 0;
}

/* Pricing Examples */
.pricing-examples-section {
  padding: 4rem 0;
  background: white;
}

.examples-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  gap: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}

.example-card {
  background: linear-gradient(135deg, #ffffff, #f8f9fa);
  padding: 2rem;
  border-radius: 16px;
  box-shadow: 0 4px 16px rgba(0,0,0,0.08);
  border: 2px solid #e9ecef;
}

.example-card h3 {
  font-size: 1.25rem;
  font-weight: 700;
  margin-bottom: 1.5rem;
  color: #1a1a2e;
  text-align: center;
}

.example-calc {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.calc-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  background: white;
  border-radius: 8px;
  border: 1px solid #dee2e6;
}

.calc-row.highlight {
  background: linear-gradient(135deg, #f0fdf4, #dcfce7);
  border-color: #86efac;
  font-weight: 600;
}

.calc-row.best {
  background: linear-gradient(135deg, #fff7ed, #fed7aa);
  border-color: #fdba74;
}

.calc-row .price {
  text-align: right;
}

.savings {
  margin-top: 1rem;
  padding: 1rem;
  background: linear-gradient(135deg, #28a745, #20c997);
  color: white;
  border-radius: 8px;
  text-align: center;
  font-weight: 700;
  font-size: 0.875rem;
}

.savings.premium {
  background: linear-gradient(135deg, #FF6B6B, #4ECDC4);
  font-size: 1rem;
}

/* FAQ Section */
.faq-section {
  padding: 4rem 0;
}

.faq-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}

.faq-item {
  background: white;
  padding: 2rem;
  border-radius: 16px;
  box-shadow: 0 4px 16px rgba(0,0,0,0.08);
  border-left: 4px solid #667eea;
}

.faq-question {
  font-size: 1.25rem;
  font-weight: 700;
  margin-bottom: 1rem;
  color: #1a1a2e;
}

.faq-answer {
  color: #495057;
  line-height: 1.6;
  margin: 0;
}

/* CTA Section */
.cta-section {
  padding: 4rem 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 32px;
  margin: 3rem 0;
  text-align: center;
  color: white;
}

.cta-content h2 {
  font-size: 2.5rem;
  font-weight: 800;
  margin-bottom: 1rem;
}

.cta-content p {
  font-size: 1.25rem;
  margin-bottom: 2rem;
  opacity: 0.95;
}

.cta-info {
  margin: 2rem 0;
  padding: 1.5rem;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  backdrop-filter: blur(10px);
}

.cta-contact {
  font-size: 1.125rem;
  margin-bottom: 0.75rem;
  line-height: 1.8;
}

.cta-hours {
  font-size: 1rem;
  opacity: 0.9;
  margin: 0;
}

.cta-buttons {
  display: flex;
  gap: 1rem;
  justify-content: center;
  flex-wrap: wrap;
}

/* Responsive */
@media (max-width: 768px) {
  .hero-title {
    font-size: 2rem;
  }

  .hero-subtitle {
    font-size: 1.125rem;
  }

  .section-title {
    font-size: 1.75rem;
  }

  .tiers-grid {
    grid-template-columns: 1fr;
  }

  .examples-grid {
    grid-template-columns: 1fr;
  }

  .faq-grid {
    grid-template-columns: 1fr;
  }

  .cta-buttons {
    flex-direction: column;
  }

  .cta-buttons .btn {
    width: 100%;
  }
}
</style>

