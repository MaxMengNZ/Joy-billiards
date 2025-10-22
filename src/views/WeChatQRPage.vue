<template>
  <div class="wechat-qr-page">
    <div class="qr-container">
      <div class="qr-card">
        <div class="qr-header">
          <div class="wechat-icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="#09b83e">
              <path d="M8.691 2.188C3.891 2.188 0 5.476 0 9.53c0 2.212 1.17 4.203 3.002 5.55a.59.59 0 0 1 .213.665l-.39 1.48c-.019.07-.048.141-.048.213 0 .163.13.295.29.295a.326.326 0 0 0 .167-.054l1.903-1.114a.864.864 0 0 1 .717-.098 10.16 10.16 0 0 0 2.837.403c.276 0 .543-.027.811-.05-.857-2.578.157-4.972 2.733-6.518C10.76 7.688 8.691 2.188 8.691 2.188zm-2.328 5.49c.42 0 .761.34.761.76 0 .42-.34.761-.76.761-.42 0-.761-.34-.761-.76 0-.42.34-.761.76-.761zm4.68 0c.42 0 .761.34.761.76 0 .42-.34.761-.761.761-.42 0-.761-.34-.761-.76 0-.42.34-.761.761-.761zm3.326 1.983c-4.028 0-7.268 2.682-7.268 5.99 0 1.852 1.018 3.513 2.59 4.64a.548.548 0 0 1 .195.615l-.333 1.288c-.014.061-.038.123-.038.185 0 .142.11.256.25.256a.29.29 0 0 0 .144-.047l1.635-.967a.752.752 0 0 1 .616-.085 8.846 8.846 0 0 0 2.209.342c4.028 0 7.268-2.683 7.268-5.99 0-3.308-3.24-5.99-7.268-5.99zm-2.772 3.993c.39 0 .707.317.707.707a.707.707 0 1 1-1.414 0c0-.39.317-.707.707-.707zm4.438 0c.39 0 .707.317.707.707a.707.707 0 1 1-1.414 0c0-.39.317-.707.707-.707z"/>
            </svg>
          </div>
          <h1>扫码关注我们的微信</h1>
          <p class="subtitle">Scan to Follow Us on WeChat</p>
        </div>

        <div class="qr-body">
          <!-- QR Code -->
          <div class="qr-code-wrapper">
            <div class="qr-code-placeholder">
              <img 
                src="/wechat-qr.png" 
                alt="WeChat QR Code - JoyBilliardsNZ" 
                style="width: 200px; height: 200px; display: block; border-radius: 8px;"
                loading="lazy"
              />
            </div>
            <p class="qr-note">请用微信扫描二维码</p>
            <p class="qr-note-en">Please scan with WeChat</p>
          </div>

          <!-- Instructions -->
          <div class="instructions">
            <h3>如何添加我们？</h3>
            <ol>
              <li>
                <span class="step-number">1</span>
                <span class="step-text">打开微信 APP</span>
              </li>
              <li>
                <span class="step-number">2</span>
                <span class="step-text">点击右上角 "+"</span>
              </li>
              <li>
                <span class="step-number">3</span>
                <span class="step-text">选择 "扫一扫"</span>
              </li>
              <li>
                <span class="step-number">4</span>
                <span class="step-text">扫描上方二维码</span>
              </li>
            </ol>
          </div>

          <!-- Contact Info -->
          <div class="contact-box">
            <h3>或直接搜索我们</h3>
            <div class="wechat-id">
              <span class="label">微信号：</span>
              <span class="value">JoyBilliardsNZ</span>
              <button class="copy-btn" @click="copyWeChatID">复制</button>
            </div>
          </div>
        </div>

        <div class="qr-footer">
          <router-link to="/" class="back-btn">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M19 12H5M12 19l-7-7 7-7"/>
            </svg>
            返回主页
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'WeChatQRPage',
  methods: {
    copyWeChatID() {
      const wechatID = 'JoyBilliardsNZ'
      
      // Modern clipboard API
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(wechatID)
          .then(() => {
            alert('微信号已复制到剪贴板！\nWeChat ID copied to clipboard!')
          })
          .catch(() => {
            this.fallbackCopy(wechatID)
          })
      } else {
        this.fallbackCopy(wechatID)
      }
    },
    
    fallbackCopy(text) {
      const textArea = document.createElement('textarea')
      textArea.value = text
      textArea.style.position = 'fixed'
      textArea.style.left = '-999999px'
      document.body.appendChild(textArea)
      textArea.select()
      
      try {
        document.execCommand('copy')
        alert('微信号已复制到剪贴板！\nWeChat ID copied to clipboard!')
      } catch (err) {
        alert('请手动复制微信号：' + text)
      }
      
      document.body.removeChild(textArea)
    }
  }
}
</script>

<style scoped>
.wechat-qr-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #09b83e 0%, #07a035 100%);
  padding: 2rem;
}

.qr-container {
  width: 100%;
  max-width: 600px;
}

.qr-card {
  background: white;
  border-radius: 20px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  overflow: hidden;
}

.qr-header {
  background: linear-gradient(135deg, #09b83e, #07a035);
  color: white;
  padding: 2rem;
  text-align: center;
}

.wechat-icon {
  margin-bottom: 1rem;
}

.qr-header h1 {
  font-size: 1.75rem;
  margin: 0 0 0.5rem 0;
  font-weight: 700;
}

.subtitle {
  margin: 0;
  opacity: 0.9;
  font-size: 0.95rem;
}

.qr-body {
  padding: 2rem;
}

.qr-code-wrapper {
  text-align: center;
  margin-bottom: 2rem;
  padding: 2rem;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  border-radius: 16px;
}

.qr-code-placeholder {
  display: inline-block;
  padding: 20px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.qr-note {
  margin: 1rem 0 0.25rem 0;
  font-size: 1rem;
  font-weight: 600;
  color: #09b83e;
}

.qr-note-en {
  margin: 0;
  font-size: 0.875rem;
  color: #6c757d;
}

.instructions {
  margin-bottom: 2rem;
}

.instructions h3 {
  font-size: 1.25rem;
  margin-bottom: 1rem;
  color: #333;
}

.instructions ol {
  list-style: none;
  padding: 0;
  margin: 0;
}

.instructions li {
  display: flex;
  align-items: center;
  padding: 0.75rem;
  margin-bottom: 0.5rem;
  background: #f8f9fa;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.instructions li:hover {
  background: #e9ecef;
  transform: translateX(4px);
}

.step-number {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  background: #09b83e;
  color: white;
  border-radius: 50%;
  font-weight: 700;
  margin-right: 1rem;
  flex-shrink: 0;
}

.step-text {
  font-size: 1rem;
  color: #333;
}

.contact-box {
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  padding: 1.5rem;
  border-radius: 12px;
  text-align: center;
}

.contact-box h3 {
  font-size: 1.1rem;
  margin: 0 0 1rem 0;
  color: #333;
}

.wechat-id {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.label {
  font-size: 0.95rem;
  color: #6c757d;
}

.value {
  font-size: 1.1rem;
  font-weight: 700;
  color: #09b83e;
  font-family: 'Courier New', monospace;
}

.copy-btn {
  padding: 0.5rem 1rem;
  background: #09b83e;
  color: white;
  border: none;
  border-radius: 6px;
  font-size: 0.875rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.copy-btn:hover {
  background: #07a035;
  transform: scale(1.05);
}

.copy-btn:active {
  transform: scale(0.95);
}

.qr-footer {
  padding: 1.5rem;
  text-align: center;
  border-top: 1px solid #e9ecef;
}

.back-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem;
  background: #f8f9fa;
  color: #333;
  text-decoration: none;
  border-radius: 8px;
  font-weight: 600;
  transition: all 0.3s ease;
}

.back-btn:hover {
  background: #e9ecef;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

/* Mobile Optimization */
@media (max-width: 768px) {
  .wechat-qr-page {
    padding: 1rem;
    align-items: flex-start;
    padding-top: 2rem;
  }

  .qr-header {
    padding: 1.5rem;
  }

  .qr-header h1 {
    font-size: 1.5rem;
  }

  .qr-body {
    padding: 1.5rem;
  }

  .qr-code-wrapper {
    padding: 1.5rem;
  }

  .qr-code-placeholder svg {
    width: 180px;
    height: 180px;
  }

  .instructions li {
    padding: 0.625rem;
  }

  .step-number {
    width: 28px;
    height: 28px;
    font-size: 0.875rem;
  }

  .step-text {
    font-size: 0.9rem;
  }

  .wechat-id {
    flex-direction: column;
    gap: 0.75rem;
  }

  .copy-btn {
    width: 100%;
  }
}
</style>

