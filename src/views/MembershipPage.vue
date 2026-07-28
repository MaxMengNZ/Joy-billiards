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
          <span class="badge-text">{{ t('membershipPage.badge') }}</span>
        </div>
        <h1 class="hero-title">
          {{ t('membershipPage.titleBefore') }} <span class="title-highlight">Joy Billiards</span> {{ t('membershipPage.titleAfter') }}
        </h1>
        <p class="hero-subtitle">
          {{ t('membershipPage.subtitle') }}
        </p>
        <div class="hero-stats">
          <div class="hero-stat-item">
            <div class="hero-stat-number">4</div>
            <div class="hero-stat-label">{{ t('membershipPage.tiersCount') }}</div>
          </div>
          <div class="hero-stat-item">
            <div class="hero-stat-number">$6</div>
            <div class="hero-stat-label">{{ t('membershipPage.maxSaving') }}</div>
          </div>
          <div class="hero-stat-item">
            <div class="hero-stat-number">1.6x</div>
            <div class="hero-stat-label">{{ t('membershipPage.maxMultiplier') }}</div>
          </div>
        </div>
      </div>
    </section>

    <div class="membership-content">

    <!-- Price Drop Announcement Banner -->
    <div class="price-drop-banner">
      <div class="banner-flash">🎉</div>
      <div class="banner-content">
        <div class="banner-tag">{{ t('membershipPage.openingSpecial') }}</div>
        <h2 class="banner-title">🔥 {{ t('membershipPage.priceReduced') }} 🔥</h2>
        <div class="price-comparison">
          <div class="price-old">
            <span class="old-label">{{ t('membershipPage.was') }}</span>
            <span class="old-price">Q7 $28/h | Q8 $33/h</span>
          </div>
          <div class="price-arrow">→</div>
          <div class="price-new">
            <span class="new-label">{{ t('membershipPage.now') }}</span>
            <span class="new-price">Q7 $23/h | Q8 $28/h</span>
          </div>
          <div class="price-save">
            <span class="save-badge">{{ t('membershipPage.savePerHour') }}</span>
          </div>
        </div>
        <p class="banner-subtitle">
          💰 <strong>{{ t('membershipPage.noFees') }}</strong> {{ t('membershipPage.topUpExplanation') }}
        </p>
      </div>
    </div>

    <!-- Membership Tiers -->
    <section class="tiers-section">
      <h2 class="section-title">{{ t('membershipPage.chooseLevel') }}</h2>
      
      <!-- Mobile: Tabs for tier selection -->
      <div class="mobile-tier-tabs">
        <button 
          v-for="tier in tierTabs" 
          :key="tier.id"
          class="tier-tab-btn"
          :class="{ active: activeTier === tier.id }"
          @click="activeTier = tier.id"
        >
          <span class="tier-tab-icon">{{ tier.icon }}</span>
          <span class="tier-tab-label">{{ tier.label }}</span>
        </button>
      </div>

      <div class="tiers-grid">
        <!-- Lite -->
        <div class="tier-card tier-lite" :class="{ 'mobile-hidden': activeTier !== 'lite' }">
          <div class="tier-header">
            <div class="tier-icon">🎱</div>
            <h3 class="tier-name">Lite</h3>
            <p class="tier-tagline">{{ t('membershipPage.casualPlayers') }}</p>
          </div>
          <div class="tier-price">
            <span class="price-amount">{{ t('membershipPage.free') }}</span>
            <span class="price-period">{{ t('membershipPage.forever') }}</span>
          </div>
          <ul class="tier-features">
            <li><span class="feature-icon">✅</span> {{ t('membershipPage.freeRegistration') }}</li>
            <li><span class="feature-icon">🎱</span> Q7 (Silver Leg): $23/h | Q8 (Gold Leg): $28/h</li>
            <li><span class="feature-icon">🎯</span> {{ t('membershipPage.basicCues') }}</li>
            <li><span class="feature-icon">📊</span> {{ t('membershipPage.basicStats') }}</li>
            <li><span class="feature-icon">📅</span> {{ t('membershipPage.sameDayBooking') }}</li>
            <li><span class="feature-icon">💰</span> {{ t('membershipPage.loyaltyPoints', { multiplier: '1.0x' }) }}</li>
          </ul>
          <div class="lite-note">{{ t('membershipPage.allPricesGst') }}</div>
          <button class="btn btn-secondary btn-lg" @click="scrollToSignup">{{ t('membershipPage.joinFree') }}</button>
        </div>

        <!-- Plus -->
        <div class="tier-card tier-plus" :class="{ 'mobile-hidden': activeTier !== 'plus' }">
          <div class="tier-header">
            <div class="tier-icon">⭐</div>
            <h3 class="tier-name">Plus</h3>
            <p class="tier-tagline">{{ t('membershipPage.regularPlayers') }}</p>
          </div>
          <div class="tier-price">
            <span class="price-amount">{{ t('membershipPage.topUp', { amount: 200 }) }}</span>
            <span class="price-period">{{ t('membershipPage.prepaidNote') }}</span>
          </div>
          <ul class="tier-features">
            <li><span class="feature-icon">💳</span> <strong>{{ t('membershipPage.memberRates') }}</strong> Q7: $21/h | Q8: $26/h</li>
            <li><span class="feature-icon">💰</span> {{ t('membershipPage.playingCredit', { amount: 200 }) }}</li>
            <li><span class="feature-icon">⭐</span> {{ t('membershipPage.fasterPoints', { multiplier: '1.2x' }) }}</li>
            <li><span class="feature-icon">🎯</span> {{ t('membershipPage.premiumCues') }}</li>
            <li><span class="feature-icon">📅</span> {{ t('membershipPage.priorityBooking', { hours: 6 }) }}</li>
          </ul>
          <div class="pricing-clarification">
            <div class="clarification-title">💡 {{ t('membershipPage.howItWorks') }}</div>
            <div class="clarification-item">
              <span class="clarification-label">{{ t('membershipPage.topUpStep', { amount: 200 }) }}</span>
              <span class="clarification-value">{{ t('membershipPage.getCredit', { amount: 200 }) }}</span>
            </div>
            <div class="clarification-item">
              <span class="clarification-label">{{ t('membershipPage.playPay') }}</span>
              <span class="clarification-value">$21/h (Q7) | $26/h (Q8)</span>
            </div>
            <div class="clarification-note">
              {{ t('membershipPage.noMembershipFee') }}
            </div>
          </div>
          <div class="savings-badge">{{ t('membershipPage.plusSaving') }}</div>
          <button class="btn btn-primary btn-lg" @click="contactUs">{{ t('membershipPage.upgradeNow') }}</button>
        </div>

        <!-- Pro -->
        <div class="tier-card tier-pro recommended" :class="{ 'mobile-hidden': activeTier !== 'pro' }">
          <div class="recommended-badge">⭐ {{ t('membershipPage.popular') }}</div>
          <div class="tier-header">
            <div class="tier-icon">💎</div>
            <h3 class="tier-name">Pro</h3>
            <p class="tier-tagline">{{ t('membershipPage.seriousPlayers') }}</p>
          </div>
          <div class="tier-price">
            <span class="price-amount">{{ t('membershipPage.topUp', { amount: 500 }) }}</span>
            <span class="price-period">{{ t('membershipPage.prepaidNote') }}</span>
          </div>
          <ul class="tier-features">
            <li><span class="feature-icon">💳</span> <strong>{{ t('membershipPage.memberRates') }}</strong> Q7: $19/h | Q8: $24/h</li>
            <li><span class="feature-icon">💰</span> {{ t('membershipPage.playingCredit', { amount: 500 }) }}</li>
            <li><span class="feature-icon">⭐</span> {{ t('membershipPage.fasterPoints', { multiplier: '1.4x' }) }}</li>
            <li><span class="feature-icon">🎯</span> {{ t('membershipPage.premiumCues') }}</li>
            <li><span class="feature-icon">📅</span> {{ t('membershipPage.priorityBooking', { hours: 12 }) }}</li>
            <li><span class="feature-icon">🎖️</span> {{ t('membershipPage.tournamentPriority') }}</li>
          </ul>
          <div class="pricing-clarification">
            <div class="clarification-title">💡 {{ t('membershipPage.howItWorks') }}</div>
            <div class="clarification-item">
              <span class="clarification-label">{{ t('membershipPage.topUpStep', { amount: 500 }) }}</span>
              <span class="clarification-value">{{ t('membershipPage.getCredit', { amount: 500 }) }}</span>
            </div>
            <div class="clarification-item">
              <span class="clarification-label">{{ t('membershipPage.playPay') }}</span>
              <span class="clarification-value">$19/h (Q7) | $24/h (Q8)</span>
            </div>
            <div class="clarification-note">
              {{ t('membershipPage.noMembershipFee') }}
            </div>
          </div>
          <div class="savings-badge">{{ t('membershipPage.proSaving') }}</div>
          <button class="btn btn-success btn-lg" @click="contactUs">{{ t('membershipPage.upgradeNow') }}</button>
        </div>

        <!-- Pro Max -->
        <div class="tier-card tier-pro-max vip" :class="{ 'mobile-hidden': activeTier !== 'pro_max' }">
          <div class="vip-badge">👑 {{ t('membershipPage.limitedSeats') }}</div>
          <div class="tier-header">
            <div class="tier-icon">🌟</div>
            <h3 class="tier-name">Pro Max</h3>
            <p class="tier-tagline">{{ t('membershipPage.vipExperience') }}</p>
          </div>
          <div class="tier-price">
            <span class="price-amount">{{ t('membershipPage.topUp', { amount: 1000 }) }}</span>
            <span class="price-period">{{ t('membershipPage.prepaidNote') }}</span>
          </div>
          <ul class="tier-features">
            <li><span class="feature-icon">💳</span> <strong>{{ t('membershipPage.memberRates') }}</strong> Q7: $17/h | Q8: $22/h</li>
            <li><span class="feature-icon">💰</span> {{ t('membershipPage.playingCredit', { amount: 1000 }) }}</li>
            <li><span class="feature-icon">⭐</span> {{ t('membershipPage.fasterPoints', { multiplier: '1.6x' }) }}</li>
            <li><span class="feature-icon">🎯</span> {{ t('membershipPage.premiumCues') }}</li>
            <li><span class="feature-icon">📅</span> {{ t('membershipPage.vipPriorityBooking') }}</li>
            <li><span class="feature-icon">🎂</span> {{ t('membershipPage.birthdayGift') }}</li>
          </ul>
          <div class="pricing-clarification pricing-clarification-vip">
            <div class="clarification-title">💡 {{ t('membershipPage.vipHowItWorks') }}</div>
            <div class="clarification-item">
              <span class="clarification-label">{{ t('membershipPage.topUpStep', { amount: 1000 }) }}</span>
              <span class="clarification-value">{{ t('membershipPage.getCredit', { amount: 1000 }) }}</span>
            </div>
            <div class="clarification-item">
              <span class="clarification-label">{{ t('membershipPage.playPay') }}</span>
              <span class="clarification-value"><strong>$17/h (Q7) | $22/h (Q8)</strong></span>
            </div>
            <div class="clarification-note clarification-note-vip">
              {{ t('membershipPage.vipNoFee') }}
            </div>
          </div>
          <div class="savings-badge premium">{{ t('membershipPage.proMaxSaving') }}</div>
          <button class="btn btn-warning btn-lg" @click="contactUs">{{ t('membershipPage.applyVip') }}</button>
        </div>
      </div>
    </section>

    <!-- Comparison Table -->
    <section class="comparison-section">
      <h2 class="section-title">{{ t('membershipPage.featureComparison') }}</h2>
      <div class="table-container">
        <table class="comparison-table">
          <thead>
            <tr>
              <th class="feature-column">{{ t('membershipPage.features') }}</th>
              <th class="tier-column lite">🎱 Lite</th>
              <th class="tier-column plus">⭐ Plus</th>
              <th class="tier-column pro">💎 Pro</th>
              <th class="tier-column pro-max">🌟 Pro Max</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td class="feature-name">{{ t('membershipPage.entryRequirement') }}</td>
              <td>{{ t('membershipPage.free') }}</td>
              <td>≥ $200</td>
              <td>≥ $500</td>
              <td class="best">≥ $1000</td>
            </tr>
            <tr>
              <td class="feature-name">{{ t('membershipPage.creditAfterTopUp') }}</td>
              <td>-</td>
              <td>$200</td>
              <td>$500</td>
              <td class="best">$1000</td>
            </tr>
            <tr>
              <td class="feature-name">{{ t('membershipPage.q7Rate') }}</td>
              <td>$23/{{ t('home.perHour') }}</td>
              <td class="highlight">$21/{{ t('home.perHour') }}</td>
              <td class="highlight">$19/{{ t('home.perHour') }}</td>
              <td class="highlight best">$17/{{ t('home.perHour') }}</td>
            </tr>
            <tr>
              <td class="feature-name">{{ t('membershipPage.q8Rate') }}</td>
              <td>$28/{{ t('home.perHour') }}</td>
              <td class="highlight">$26/{{ t('home.perHour') }}</td>
              <td class="highlight">$24/{{ t('home.perHour') }}</td>
              <td class="highlight best">$22/{{ t('home.perHour') }}</td>
            </tr>
            <tr>
              <td class="feature-name">{{ t('membershipPage.priorityBookingLabel') }}</td>
              <td>{{ t('membershipPage.sameDay2h') }}</td>
              <td>{{ t('membershipPage.advanceHours', { hours: 6 }) }}</td>
              <td class="highlight">{{ t('membershipPage.advanceHours', { hours: 12 }) }}</td>
              <td class="best">{{ t('membershipPage.vipPriorityBooking') }}</td>
            </tr>
            <tr>
              <td class="feature-name">{{ t('membershipPage.equipment') }}</td>
              <td>{{ t('membershipPage.basicCues') }}</td>
              <td>{{ t('membershipPage.premiumCuesShort') }}</td>
              <td>{{ t('membershipPage.premiumCuesShort') }}</td>
              <td class="best">{{ t('membershipPage.premiumCuesShort') }}</td>
            </tr>
            <tr>
              <td class="feature-name">{{ t('membershipPage.loyaltyPoints', { multiplier: '' }) }}</td>
              <td>1.0x</td>
              <td>1.2x</td>
              <td>1.4x</td>
              <td class="best">1.6x</td>
            </tr>
            <tr>
              <td class="feature-name">{{ t('membershipPage.birthdayGiftLabel') }}</td>
              <td>-</td>
              <td>-</td>
              <td>-</td>
              <td class="best">✅ {{ t('membershipPage.exclusive') }}</td>
            </tr>
            <tr>
              <td class="feature-name">{{ t('membershipPage.availability') }}</td>
              <td>{{ t('membershipPage.unlimited') }}</td>
              <td>{{ t('membershipPage.unlimited') }}</td>
              <td>{{ t('membershipPage.unlimited') }}</td>
              <td class="best">⚠️ {{ t('membershipPage.limitedSlots') }}</td>
            </tr>
            <tr>
              <td class="feature-name">{{ t('membershipPage.accountValidity') }}</td>
              <td>{{ t('membershipPage.permanent') }}</td>
              <td>{{ t('membershipPage.months12') }}</td>
              <td>{{ t('membershipPage.months12') }}</td>
              <td>{{ t('membershipPage.months12') }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>

    <!-- How It Works -->
    <section class="how-it-works-section">
      <h2 class="section-title">{{ t('membershipPage.howItWorks') }}</h2>
      <div class="steps-grid">
        <div class="step-card">
          <div class="step-number">1</div>
          <div class="step-icon">📝</div>
          <h3>{{ t('membershipPage.register') }}</h3>
          <p>{{ t('membershipPage.registerDesc') }}</p>
        </div>
        <div class="step-card">
          <div class="step-number">2</div>
          <div class="step-icon">💳</div>
          <h3>{{ t('membershipPage.recharge') }}</h3>
          <p>{{ t('membershipPage.rechargeDesc') }}</p>
        </div>
        <div class="step-card">
          <div class="step-number">3</div>
          <div class="step-icon">🎱</div>
          <h3>{{ t('membershipPage.playAndSave') }}</h3>
          <p>{{ t('membershipPage.playAndSaveDesc') }}</p>
        </div>
        <div class="step-card">
          <div class="step-number">4</div>
          <div class="step-icon">⭐</div>
          <h3>{{ t('membershipPage.earnPoints') }}</h3>
          <p>{{ t('membershipPage.earnPointsDesc') }}</p>
        </div>
      </div>
    </section>

    <!-- Benefits Details -->
    <section class="benefits-section">
      <h2 class="section-title">{{ t('membershipPage.benefitsDetails') }}</h2>
      <div class="benefits-grid">
        <div class="benefit-card">
          <div class="benefit-icon">💰</div>
          <h3>{{ t('membershipPage.saveAnytime') }}</h3>
          <p>{{ t('membershipPage.saveAnytimeDesc') }}</p>
        </div>
        <div class="benefit-card">
          <div class="benefit-icon">💰</div>
          <h3>{{ t('membershipPage.transparentPricing') }}</h3>
          <p>{{ t('membershipPage.transparentPricingDesc') }}</p>
        </div>
        <div class="benefit-card">
          <div class="benefit-icon">📅</div>
          <h3>{{ t('membershipPage.bookAhead') }}</h3>
          <p>{{ t('membershipPage.bookAheadDesc') }}</p>
        </div>
        <div class="benefit-card">
          <div class="benefit-icon">👑</div>
          <h3>{{ t('membershipPage.proMaxLimited') }}</h3>
          <p>{{ t('membershipPage.proMaxLimitedDesc') }}</p>
        </div>
        <div class="benefit-card">
          <div class="benefit-icon">🎂</div>
          <h3>{{ t('membershipPage.birthdaySurprise') }}</h3>
          <p>{{ t('membershipPage.birthdaySurpriseDesc') }}</p>
        </div>
        <div class="benefit-card">
          <div class="benefit-icon">😊</div>
          <h3>{{ t('membershipPage.firstForgiven') }}</h3>
          <p>{{ t('membershipPage.firstForgivenDesc') }}</p>
        </div>
      </div>
    </section>

    <!-- Important Notes -->
    <section class="notes-section">
      <div class="notes-card">
        <h2 class="card-title">💡 {{ t('membershipPage.importantInfo') }}</h2>
        <div class="notes-content">
          <div class="note-item">
            <span class="note-icon">✨</span>
            <div class="note-text">
              <strong>{{ t('membershipPage.memberRatesAnytimeTitle') }}</strong> {{ t('membershipPage.memberRatesAnytimeText') }}
            </div>
          </div>
          <div class="note-item">
            <span class="note-icon">🕐</span>
            <div class="note-text">
              <strong>{{ t('membershipPage.freeHoursTitle') }}</strong> {{ t('membershipPage.freeHoursText') }}
            </div>
          </div>
          <div class="note-item">
            <span class="note-icon">📅</span>
            <div class="note-text">
              <strong>{{ t('membershipPage.bookingCancellationTitle') }}</strong> {{ t('membershipPage.bookingCancellationText') }}
            </div>
          </div>
          <div class="note-item">
            <span class="note-icon">👑</span>
            <div class="note-text">
              <strong>{{ t('membershipPage.limitedTitle') }}</strong> {{ t('membershipPage.limitedText') }}
            </div>
          </div>
          <div class="note-item">
            <span class="note-icon">❌</span>
            <div class="note-text">
              <strong>{{ t('membershipPage.nonRefundableTitle') }}</strong> {{ t('membershipPage.nonRefundableText') }}
            </div>
          </div>
          <div class="note-item">
            <span class="note-icon">📉</span>
            <div class="note-text">
              <strong>{{ t('membershipPage.tierAdjustmentTitle') }}</strong> {{ t('membershipPage.tierAdjustmentText') }}
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Additional Benefits -->
    <section class="additional-benefits-section">
      <h2 class="section-title">{{ t('membershipPage.additionalBenefits') }}</h2>
      <div class="row">
        <div class="col col-2">
          <div class="benefit-detail-card">
            <div class="benefit-detail-icon">⭐</div>
            <h3>{{ t('membershipPage.loyaltySystem') }}</h3>
            <p class="benefit-description">{{ t('membershipPage.loyaltySystemDesc') }}</p>
            <ul class="benefit-list">
              <li>Lite: 1.0x | Plus: 1.2x | Pro: 1.4x | Pro Max: 1.6x</li>
              <li>{{ t('membershipPage.redeemOffPeak') }}</li>
              <li>{{ t('membershipPage.exchangeFood') }}</li>
              <li>{{ t('membershipPage.equipmentAccessories') }}</li>
              <li>{{ t('membershipPage.rollingValidity') }}</li>
            </ul>
          </div>
        </div>
        <div class="col col-2">
          <div class="benefit-detail-card">
            <div class="benefit-detail-icon">🎉</div>
            <h3>{{ t('membershipPage.memberEvents') }}</h3>
            <p class="benefit-description">{{ t('membershipPage.memberEventsDesc') }}</p>
            <ul class="benefit-list">
              <li>{{ t('membershipPage.monthlyEvents') }}</li>
              <li>{{ t('membershipPage.quarterlyVip') }}</li>
              <li>{{ t('membershipPage.socialNights') }}</li>
              <li>{{ t('membershipPage.discountDays') }}</li>
            </ul>
          </div>
        </div>
      </div>
    </section>

    <!-- Pricing Examples -->
    <section class="pricing-examples-section">
      <h2 class="section-title">{{ t('membershipPage.pricingExamples') }}</h2>
      <div class="examples-grid">
        <div class="example-card">
          <h3>🎱 {{ t('membershipPage.casualExample') }}</h3>
          <div class="example-calc">
            <div class="calc-row">
              <span>Lite {{ t('membershipPage.memberSuffix') }}</span>
              <span class="price">$23 × 2h × 4 = <strong>$184{{ t('membershipPage.perMonth') }}</strong></span>
            </div>
            <div class="calc-row highlight">
              <span>Plus {{ t('membershipPage.memberSuffix') }}</span>
              <span class="price">$21 × 2h × 4 = <strong>$168{{ t('membershipPage.perMonth') }}</strong></span>
            </div>
            <div class="savings">💰 {{ t('membershipPage.saveMonthly', { month: 16, year: 192 }) }}</div>
          </div>
        </div>
        <div class="example-card">
          <h3>🏆 {{ t('membershipPage.regularExample') }}</h3>
          <div class="example-calc">
            <div class="calc-row">
              <span>Lite {{ t('membershipPage.memberSuffix') }}</span>
              <span class="price">$23 × 10h × 4 = <strong>$920{{ t('membershipPage.perMonth') }}</strong></span>
            </div>
            <div class="calc-row highlight">
              <span>Pro {{ t('membershipPage.memberSuffix') }}</span>
              <span class="price">$19 × 10h × 4 = <strong>$760{{ t('membershipPage.perMonth') }}</strong></span>
            </div>
            <div class="savings">💰 {{ t('membershipPage.saveMonthly', { month: 160, year: '1,920' }) }}</div>
          </div>
        </div>
        <div class="example-card">
          <h3>💎 {{ t('membershipPage.enthusiastExample') }}</h3>
          <div class="example-calc">
            <div class="calc-row">
              <span>Lite {{ t('membershipPage.memberSuffix') }}</span>
              <span class="price">$23 × 10h × 4 = <strong>$920{{ t('membershipPage.perMonth') }}</strong></span>
            </div>
            <div class="calc-row highlight best">
              <span>Pro Max {{ t('membershipPage.memberSuffix') }}</span>
              <span class="price">$17 × 10h × 4 = <strong>$680{{ t('membershipPage.perMonth') }}</strong></span>
            </div>
            <div class="savings premium">💎 {{ t('membershipPage.vipSaveMonthly') }}</div>
          </div>
        </div>
      </div>
    </section>

    <!-- FAQ Section -->
    <section class="faq-section">
      <h2 class="section-title">{{ t('membershipPage.faq') }}</h2>
      <div class="faq-grid">
        <div class="faq-item">
          <h3 class="faq-question">💰 {{ t('membershipPage.faqWeekendQ') }}</h3>
          <p class="faq-answer">{{ t('membershipPage.faqWeekendA') }}</p>
        </div>
        <div class="faq-item">
          <h3 class="faq-question">👑 {{ t('membershipPage.faqLimitedQ') }}</h3>
          <p class="faq-answer">{{ t('membershipPage.faqLimitedA') }}</p>
        </div>
        <div class="faq-item">
          <h3 class="faq-question">🎁 {{ t('membershipPage.faqMissQ') }}</h3>
          <p class="faq-answer">{{ t('membershipPage.faqMissA') }}</p>
        </div>
        <div class="faq-item">
          <h3 class="faq-question">📅 {{ t('membershipPage.faqBookingQ') }}</h3>
          <p class="faq-answer">{{ t('membershipPage.faqBookingA') }}</p>
        </div>
        <div class="faq-item">
          <h3 class="faq-question">⭐ {{ t('membershipPage.faqPointsQ') }}</h3>
          <p class="faq-answer">{{ t('membershipPage.faqPointsA') }}</p>
        </div>
        <div class="faq-item">
          <h3 class="faq-question">🎂 {{ t('membershipPage.faqBirthdayQ') }}</h3>
          <p class="faq-answer">{{ t('membershipPage.faqBirthdayA') }}</p>
        </div>
      </div>
    </section>

    <!-- Call to Action -->
    <section class="cta-section">
      <div class="cta-content">
        <h2>{{ t('membershipPage.ctaTitle') }}</h2>
        <p>{{ t('membershipPage.ctaDesc') }}</p>
        <div class="cta-info">
          <p class="cta-contact">
            📍 88 Tristram Street, Hamilton Central<br>
            📞 022 166 0688 | 📧 info@joybilliards.co.nz
          </p>
          <p class="cta-hours">
            ⏰ {{ t('membershipPage.ctaHours') }}
          </p>
        </div>
        <div class="cta-buttons">
          <router-link to="/register" class="btn btn-primary btn-lg">
            🎱 {{ t('membershipPage.joinNow') }}
          </router-link>
          <button class="btn btn-warning btn-lg" @click="contactUs">
            📞 {{ t('membershipPage.callNow') }}
          </button>
        </div>
      </div>
    </section>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue'
import { useI18n } from '../i18n'

export default {
  name: 'MembershipPage',
  setup() {
    const { t } = useI18n()
    const activeTier = ref('plus') // Default to Plus (most popular)

    const tierTabs = [
      { id: 'lite', icon: '🎱', label: 'Lite' },
      { id: 'plus', icon: '⭐', label: 'Plus' },
      { id: 'pro', icon: '💎', label: 'Pro' },
      { id: 'pro_max', icon: '🌟', label: 'Pro M' }
    ]

    const scrollToSignup = () => {
      window.scrollTo({ top: document.body.scrollHeight, behavior: 'smooth' })
    }

    const contactUs = () => {
      window.location.href = 'tel:0221660688'
    }

    return {
      activeTier,
      t,
      tierTabs,
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

/* Price Drop Banner */
.price-drop-banner {
  background: linear-gradient(135deg, #dc2626 0%, #ef4444 50%, #f97316 100%);
  border: 4px solid #991b1b;
  border-radius: 20px;
  padding: 2.5rem;
  margin: 2rem auto 3rem;
  max-width: 1200px;
  position: relative;
  overflow: hidden;
  box-shadow: 0 12px 40px rgba(220, 38, 38, 0.4);
  animation: banner-pulse 2s ease-in-out infinite;
}

@keyframes banner-pulse {
  0%, 100% {
    transform: scale(1);
    box-shadow: 0 12px 40px rgba(220, 38, 38, 0.4);
  }
  50% {
    transform: scale(1.02);
    box-shadow: 0 16px 48px rgba(220, 38, 38, 0.6);
  }
}

.price-drop-banner::before {
  content: '';
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background: linear-gradient(45deg, transparent, rgba(255, 255, 255, 0.1), transparent);
  animation: shine 3s ease-in-out infinite;
}

@keyframes shine {
  0% {
    transform: translateX(-100%) translateY(-100%) rotate(45deg);
  }
  100% {
    transform: translateX(100%) translateY(100%) rotate(45deg);
  }
}

.banner-flash {
  position: absolute;
  top: 1rem;
  right: 1rem;
  font-size: 3rem;
  animation: flash-rotate 1.5s ease-in-out infinite;
}

@keyframes flash-rotate {
  0%, 100% {
    transform: rotate(0deg) scale(1);
  }
  25% {
    transform: rotate(-15deg) scale(1.2);
  }
  75% {
    transform: rotate(15deg) scale(1.2);
  }
}

.banner-content {
  position: relative;
  z-index: 1;
  text-align: center;
}

.banner-tag {
  display: inline-block;
  background: rgba(255, 255, 255, 0.95);
  color: #dc2626;
  padding: 0.5rem 1.5rem;
  border-radius: 50px;
  font-weight: 800;
  font-size: 0.9rem;
  letter-spacing: 2px;
  margin-bottom: 1rem;
  animation: tag-bounce 1s ease-in-out infinite;
}

@keyframes tag-bounce {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-5px);
  }
}

.banner-title {
  font-size: 2.5rem;
  font-weight: 900;
  color: white;
  margin: 0 0 1.5rem 0;
  text-shadow: 2px 2px 8px rgba(0, 0, 0, 0.3);
  letter-spacing: 1px;
}

.price-comparison {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 1.5rem;
  margin: 1.5rem 0;
  flex-wrap: wrap;
}

.price-old {
  background: rgba(0, 0, 0, 0.3);
  padding: 1rem 1.5rem;
  border-radius: 12px;
  text-align: center;
}

.old-label {
  display: block;
  color: rgba(255, 255, 255, 0.7);
  font-size: 0.9rem;
  margin-bottom: 0.5rem;
  text-decoration: line-through;
}

.old-price {
  display: block;
  color: rgba(255, 255, 255, 0.8);
  font-size: 1.3rem;
  font-weight: 700;
  text-decoration: line-through;
}

.price-arrow {
  font-size: 2.5rem;
  color: white;
  font-weight: 900;
  animation: arrow-pulse 1s ease-in-out infinite;
}

@keyframes arrow-pulse {
  0%, 100% {
    transform: translateX(0);
  }
  50% {
    transform: translateX(10px);
  }
}

.price-new {
  background: rgba(255, 255, 255, 0.95);
  padding: 1rem 1.5rem;
  border-radius: 12px;
  text-align: center;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);
}

.new-label {
  display: block;
  color: #dc2626;
  font-size: 0.9rem;
  font-weight: 800;
  margin-bottom: 0.5rem;
}

.new-price {
  display: block;
  color: #991b1b;
  font-size: 1.8rem;
  font-weight: 900;
}

.price-save {
  background: #fbbf24;
  padding: 0.75rem 1.5rem;
  border-radius: 50px;
  animation: save-pulse 1s ease-in-out infinite;
}

@keyframes save-pulse {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.1);
  }
}

.save-badge {
  color: #78350f;
  font-size: 1.2rem;
  font-weight: 900;
  letter-spacing: 1px;
}

.banner-subtitle {
  color: white;
  font-size: 1.1rem;
  line-height: 1.6;
  margin: 1.5rem 0 0 0;
  text-shadow: 1px 1px 4px rgba(0, 0, 0, 0.3);
}

.banner-subtitle strong {
  color: #fbbf24;
  font-weight: 800;
}

@media (max-width: 768px) {
  .price-drop-banner {
    padding: 2rem 1.5rem;
    margin: 1rem;
    border-radius: 16px;
  }
  
  .banner-flash {
    font-size: 2.5rem;
    top: 0.5rem;
    right: 0.5rem;
  }
  
  .banner-tag {
    font-size: 0.75rem;
    padding: 0.4rem 1rem;
    letter-spacing: 1px;
  }
  
  .banner-title {
    font-size: 1.5rem;
    line-height: 1.3;
    margin-bottom: 1rem;
  }
  
  .price-comparison {
    flex-direction: column;
    gap: 0.75rem;
  }
  
  .price-old,
  .price-new {
    width: 100%;
    padding: 0.75rem 1rem;
  }
  
  .old-price,
  .new-price {
    font-size: 1.2rem;
  }
  
  .price-arrow {
    transform: rotate(90deg);
    font-size: 2rem;
    margin: 0;
  }
  
  .price-save {
    width: 100%;
    padding: 0.6rem 1rem;
  }
  
  .save-badge {
    font-size: 1rem;
  }
  
  .banner-subtitle {
    font-size: 0.95rem;
    line-height: 1.5;
  }
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

/* Pricing Clarification Box */
.pricing-clarification {
  background: linear-gradient(135deg, #fff9e6 0%, #fff4d6 100%);
  border: 2px solid #fbbf24;
  border-radius: 12px;
  padding: 1rem;
  margin-bottom: 1.5rem;
  position: relative;
  z-index: 2;
}

.pricing-clarification-vip {
  background: linear-gradient(135deg, #fff0f5 0%, #ffe4f0 100%);
  border: 2px solid #ec4899;
}

.clarification-title {
  font-size: 0.85rem;
  font-weight: 700;
  color: #d97706;
  margin-bottom: 0.75rem;
  text-align: center;
}

.pricing-clarification-vip .clarification-title {
  color: #c026d3;
}

.clarification-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem 0;
  border-bottom: 1px solid rgba(0, 0, 0, 0.1);
}

.clarification-item:last-of-type {
  border-bottom: none;
  margin-bottom: 0.5rem;
}

.clarification-label {
  font-size: 0.8rem;
  color: #64748b;
  font-weight: 500;
}

.clarification-value {
  font-size: 0.85rem;
  font-weight: 700;
  color: #1e293b;
}

.clarification-note {
  font-size: 0.75rem;
  color: #64748b;
  font-style: italic;
  margin-top: 0.5rem;
  padding-top: 0.75rem;
  border-top: 1px dashed rgba(0, 0, 0, 0.15);
  line-height: 1.5;
}

.clarification-note-vip {
  color: #be123c;
  font-weight: 600;
  font-style: normal;
}

.clarification-note strong {
  color: #dc2626;
  text-decoration: underline;
  font-weight: 700;
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
  
  /* Mobile: Tier Tabs */
  .mobile-tier-tabs {
    display: flex;
    justify-content: center;
    gap: 8px;
    margin-bottom: 24px;
    padding: 12px;
    background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
    border-radius: 16px;
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
  }

  .tier-tab-btn {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 4px;
    padding: 12px 16px;
    min-width: 70px;
    min-height: 70px;
    background: white;
    border: 2px solid #dee2e6;
    border-radius: 12px;
    cursor: pointer;
    transition: all 0.3s ease;
    flex-shrink: 0;
  }

  .tier-tab-btn:active {
    transform: scale(0.95);
  }

  .tier-tab-btn.active {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-color: #667eea;
    box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
  }

  .tier-tab-icon {
    font-size: 28px;
    transition: all 0.3s ease;
  }

  .tier-tab-btn.active .tier-tab-icon {
    transform: scale(1.2);
    filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.2));
  }

  .tier-tab-label {
    font-size: 12px;
    font-weight: 600;
    color: #495057;
    transition: all 0.3s ease;
  }

  .tier-tab-btn.active .tier-tab-label {
    color: white;
    font-weight: 700;
  }

  /* Mobile: Single Column Layout */
  .tiers-grid {
    display: flex;
    flex-direction: column;
    gap: 0;
  }

  .tier-card {
    width: 100%;
    max-width: none;
    margin-bottom: 0;
  }

  .tier-card.mobile-hidden {
    display: none;
  }

  /* Mobile: Simplify comparison table */
  .comparison-section {
    display: none; /* Hide on mobile, too complex */
  }

  /* Mobile: Optimize pricing examples */
  .examples-grid {
    grid-template-columns: 1fr;
  }
}

/* Desktop: Hide mobile tabs */
@media (min-width: 769px) {
  .mobile-tier-tabs {
    display: none;
  }
}
</style>
