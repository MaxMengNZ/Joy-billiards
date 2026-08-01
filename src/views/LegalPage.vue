<template>
  <div class="legal-page">
    <article class="legal-document">
      <router-link to="/" class="back-link">← Joy Billiards New Zealand</router-link>
      <p class="eyebrow">{{ document.eyebrow }}</p>
      <h1>{{ document.title }}</h1>
      <p class="subtitle">{{ document.subtitle }}</p>
      <p class="updated">Last updated 1 August 2026 · Version 1.0</p>

      <section v-for="section in document.sections" :key="section.title">
        <h2>{{ section.title }}</h2>
        <p v-for="paragraph in section.body" :key="paragraph">{{ paragraph }}</p>
      </section>

      <aside class="contact-card">
        <strong>JOY BILLIARDS NEW ZEALAND LIMITED</strong>
        <span>Company No. 9336374 · NZBN 9429052786860</span>
        <span>Trading as Joy Billiards New Zealand</span>
        <span>88 Tristram Street, Hamilton 3204, New Zealand</span>
        <a href="mailto:info@joybilliards.co.nz">info@joybilliards.co.nz</a>
        <a href="tel:+64221660688">+64 22 166 0688</a>
      </aside>
    </article>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({ kind: { type: String, required: true } })

const documents = {
  privacy: {
    eyebrow: 'PRIVACY & DATA',
    title: 'Privacy Policy · 隐私政策',
    subtitle: 'How we collect, use, protect and delete personal information in the JOY Billiards App.',
    sections: [
      { title: 'Who we are and scope', body: ['The App is operated by JOY BILLIARDS NEW ZEALAND LIMITED (Company No. 9336374; NZBN 9429052786860), trading as Joy Billiards New Zealand (“JOY”, “we”, “us”). Our Registered Office and Address for Service are 88 Tristram Street, Hamilton 3204, New Zealand.', 'This policy applies to the JOY Billiards App, member accounts and related membership, tournament, venue service, store and notification functions. We handle personal information under the New Zealand Privacy Act 2020 and its Information Privacy Principles.'] },
      { title: 'Information we collect', body: ['We may collect your name, date of birth, email address, phone number, encrypted authentication information, member number, membership level, profile image and review status.', 'We may also collect member consumption points and their ledger, tournament entries, matches, results, ranking points, win/loss statistics, bookings, repairs, coaching requests, song queues, store orders and service communications. Member consumption points and tournament ranking points are separate systems.', 'Camera access is used only when you choose to scan a code. Photo access is used only when you choose an avatar or product image. We may process push tokens, notification preferences and necessary diagnostic information.'] },
      { title: 'Why we use information', body: ['We use information where reasonably necessary to create and protect accounts, generate member numbers, provide membership and points, administer tournaments and rankings, process bookings, requests and orders, send service and security notifications, prevent fraud or duplicate awards, and meet legal obligations.', 'We do not sell personal information. Marketing choices are separate from essential account, security, order and service notices.'] },
      { title: 'Public information and profile images', body: ['An approved avatar, display name, limited member-number information, tournament entry, results, rankings and statistics may be displayed in the App, on JOY websites or at JOY events. Email, phone number, date of birth, full identity information and member consumption points are not displayed publicly.', 'Profile images are subject to review and may currently be changed once per calendar month. Completed sporting results may be retained in de-identified form to preserve the integrity of tournament records.'] },
      { title: 'Sharing and overseas processing', body: ['We disclose information only as needed to authorised staff, tournament administrators and service providers. Supabase supports account and database services; Expo/EAS may support app updates, push notifications and builds; Apple or Google process information required for their platforms and stores.', 'Where information is processed outside New Zealand, we take reasonable steps under IPP 12 to use comparable safeguards or another lawful transfer mechanism. We may also make limited disclosures where required by law or necessary to protect safety, investigate fraud or enforce legal rights.'] },
      { title: 'Retention, security and privacy incidents', body: ['We use access controls, authentication, least-privilege administration and transport protection appropriate to the risk. No online service can guarantee absolute security.', 'We retain information only for its purpose and legal, accounting, dispute or fraud-prevention requirements. Following account deletion, information is generally deleted or de-identified within 30 days, subject to backup rotation and records that the law requires us to retain.', 'If a privacy breach is likely to cause serious harm, we will notify the Office of the Privacy Commissioner and affected individuals as required by the Privacy Act 2020.'] },
      { title: 'Your rights and choices', body: ['You may request access to or correction of your personal information and may manage available permissions in device settings. You can request permanent account deletion in the App under “My → Delete Account & Personal Data”, or use the public account-deletion instructions on this website.', 'Privacy enquiries, access, correction, deletion and complaints can be sent to the Privacy Officer at info@joybilliards.co.nz or +64 22 166 0688. You may also complain to the New Zealand Office of the Privacy Commissioner at privacy.org.nz.'] },
      { title: 'Children and changes', body: ['Registration is available from age 13. Users under 18 should have a parent or guardian aware of their use, and consent may be required for payments, tournaments or in-person services.', 'We may update this policy when our practices, providers or legal obligations change. Material changes will be communicated reasonably and will not retrospectively expand use without appropriate notice or consent.'] }
    ]
  },
  terms: {
    eyebrow: 'TERMS & MEMBERSHIP',
    title: 'Terms of Service · 用户协议',
    subtitle: 'Rules for the JOY Billiards App, member accounts, tournaments, bookings, services and store.',
    sections: [
      { title: 'Agreement and eligibility', body: ['These terms are provided by JOY BILLIARDS NEW ZEALAND LIMITED (Company No. 9336374; NZBN 9429052786860), trading as Joy Billiards New Zealand. By registering, signing in or continuing to use account functions, you agree to these terms and the Privacy Policy.', 'You must be at least 13. A user under 18 should obtain parent or guardian consent, particularly for purchases, paid tournaments and in-person services. Account information must be truthful and kept secure.'] },
      { title: 'Membership, points and rankings', body: ['Membership benefits and eligibility are governed by the membership rules shown in the App or venue. Material adverse changes will be communicated reasonably.', 'Member consumption points expire 12 months after the date each entry is credited. Refunds, reversed transactions and corrections may reverse associated points. Tournament ranking points are a separate sporting record and are not subject to this member-points expiry rule.', 'Points are not cash, stored-value balance or transferable property unless a specific lawful offer says otherwise. Verifiable transaction or result errors may be corrected with a reason and audit record, and users may request manual review.'] },
      { title: 'Tournaments and cancellations', body: ['Entry means acceptance of the published eligibility, format, schedule, fee, conduct, cancellation and scoring rules. To ask about cancellation or refund eligibility before the event or registration deadline, contact +64 22 166 0688 or info@joybilliards.co.nz. An enquiry does not itself guarantee a refund; the disclosed event rules, reasonable costs already incurred and New Zealand consumer law apply.', 'If a result appears incorrect, contact staff promptly with supporting information. Approved names, avatars, entries, results, rankings and statistics may be publicly displayed.'] },
      { title: 'Bookings, coaching and repairs', body: ['Times, prices, deposits, cancellation windows and attendance requirements are shown before submission or in the venue confirmation. A request is not confirmed until its App status or a staff member confirms it.', 'For cancellation, changes or refunds, contact +64 22 166 0688 or info@joybilliards.co.nz as early as possible. Where materials have been purchased, work begun, staff time reserved or a disclosed cancellation period missed, a pre-disclosed reasonable charge proportionate to actual loss may apply. If JOY cancels, an appropriate reschedule, refund or other lawful remedy will be offered.'] },
      { title: 'Store, gift cards and consumer rights', body: ['The store may offer both paid online purchases and unpaid in-store reservations. Checkout will identify which method applies, together with price and fulfilment details.', 'Gift-card validity, expiry disclosure, restrictions and consumer rights are governed by the New Zealand law applying at the time of sale and the terms prominently presented before purchase. JOY will not apply an expiry period shorter than any mandatory legal minimum. If a gift-card term conflicts with a non-excludable legal right, the law prevails.', 'Nothing in these terms excludes or limits rights that cannot lawfully be excluded under the Consumer Guarantees Act 1993, Fair Trading Act 1986 or other New Zealand law.'] },
      { title: 'Acceptable use and enforcement', body: ['You must not use the service to break the law, harass others, cheat, manipulate results, fabricate transactions, obtain duplicate points, introduce malicious code, bypass permissions, access accounts or systems without authority, scrape personal information or disrupt JOY services.', 'Based on reasonable evidence, JOY may investigate unusual activity and proportionately restrict affected functions or disputed points. Except where urgent security, fraud or legal needs prevent it, we will provide reasons. Users can dispute a decision and request manual review. No party has a unilateral final right to interpret these terms.'] },
      { title: 'Availability, liability and termination', body: ['We take reasonable care but cannot promise uninterrupted or error-free service. Nothing limits liability for fraud, deliberate misconduct, personal injury where exclusion is unlawful, or non-excludable statutory rights.', 'You may stop using the service and request account deletion. JOY may suspend or terminate accounts for serious or repeated breaches, security risks, fraud or legal requirements. Existing payment, refund, consumer and dispute obligations survive termination.'] },
      { title: 'Law, disputes and contact', body: ['These terms are governed by New Zealand law. Please contact info@joybilliards.co.nz first so we can try to resolve a concern. You may still use the Disputes Tribunal, Commerce Commission, Privacy Commissioner or another body with jurisdiction.', 'If a provision is invalid, the minimum necessary part is severed and the rest remains effective. Specific transaction rules prevail only where clearly disclosed and lawful, and cannot reduce non-excludable rights.'] }
    ]
  },
  deletion: {
    eyebrow: 'ACCOUNT & DATA',
    title: 'Account Deletion · 删除账户',
    subtitle: 'How to permanently delete a JOY Billiards account and associated personal information.',
    sections: [
      { title: 'Delete in the App', body: ['Sign in to the JOY Billiards App, open “My”, choose “Delete Account & Personal Data”, review the consequences and complete the confirmation steps. This requests permanent deletion rather than simply signing you out or deactivating the account.'] },
      { title: 'If you cannot access the App', body: ['Email info@joybilliards.co.nz from the email address registered to the account with the subject “Account deletion request”. Include your display name and member number if known. Do not send your password. We may ask for limited information to verify that the account belongs to you. You may also call +64 22 166 0688 for assistance.'] },
      { title: 'What is deleted', body: ['After verification, we delete or de-identify the account profile, contact details, avatar and associated personal information that is no longer required. Processing is generally completed within 30 days. You will lose access to the account and deletion may not be reversible.'] },
      { title: 'What may be retained', body: ['We may retain records where required by tax, accounting, fraud-prevention, dispute or other New Zealand law. Completed tournament records may be retained without direct identity details where reasonably necessary to preserve sporting results. Secure backups may remain until normal backup rotation completes and are not used for ordinary business purposes.', 'Deleting an account does not remove outstanding payment obligations or non-excludable refund and consumer rights. For questions, contact the Privacy Officer at info@joybilliards.co.nz.'] }
    ]
  }
}

const document = computed(() => documents[props.kind] || documents.privacy)
</script>

<style scoped>
.legal-page{min-height:100vh;background:#f6f4f1;padding:56px 20px 90px;color:#171717}.legal-document{max-width:820px;margin:0 auto;background:#fff;border:1px solid #e8e3dc;border-radius:24px;padding:clamp(28px,6vw,64px);box-shadow:0 24px 70px rgba(31,24,18,.08)}.back-link{display:inline-block;margin-bottom:36px;color:#a11920;text-decoration:none;font-weight:700}.eyebrow{margin:0 0 10px;color:#b91f29;font-size:12px;font-weight:800;letter-spacing:.18em}.legal-document h1{margin:0;color:#121212;font-size:clamp(32px,6vw,52px);line-height:1.06}.subtitle{margin:18px 0 8px;color:#555;font-size:18px;line-height:1.6}.updated{margin:0 0 44px;color:#8b8580;font-size:14px}.legal-document section{padding:28px 0;border-top:1px solid #eee9e3}.legal-document h2{margin:0 0 14px;font-size:22px;color:#24201d}.legal-document section p{margin:10px 0;color:#4d4945;line-height:1.8}.contact-card{display:flex;flex-direction:column;gap:7px;margin-top:28px;padding:24px;border-left:4px solid #b91f29;border-radius:12px;background:#faf7f2;color:#403a35}.contact-card a{color:#a11920;text-decoration:none}.contact-card strong{color:#171717}@media(max-width:600px){.legal-page{padding:24px 12px 70px}.legal-document{border-radius:18px;padding:26px 20px}.updated{margin-bottom:30px}}
</style>
