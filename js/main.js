// 移动端菜单切换
function initMobileMenu() {
    const menuToggle = document.getElementById('mobileMenu');
    if (menuToggle) {
        menuToggle.addEventListener('click', function() {
            const mainNav = document.getElementById('mainNav');
            const isExpanded = this.getAttribute('aria-expanded') === 'true';
            this.setAttribute('aria-expanded', !isExpanded);
            mainNav.classList.toggle('nav-active');
            
            // 切换汉堡菜单图标
            const spans = this.querySelectorAll('span');
            this.classList.toggle('active');
        });
    }
}

// 关闭公告功能
function initAnnouncement() {
    const announcement = document.querySelector('.announcement');
    if (announcement) {
        const closeBtn = announcement.querySelector('.close-btn');
        closeBtn.addEventListener('click', function() {
            announcement.style.display = 'none';
            // 存储用户偏好到localStorage
            localStorage.setItem('announcementClosed', 'true');
        });

        // 检查用户是否已关闭过公告
        if (localStorage.getItem('announcementClosed') === 'true') {
            announcement.style.display = 'none';
        }
    }
}

// 作品预览功能
function initWorkPreview() {
    const workItems = document.querySelectorAll('.work-card');
    workItems.forEach(item => {
        item.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-8px)';
            this.style.boxShadow = '0 10px 20px rgba(0,0,0,0.1)';
        });

        item.addEventListener('mouseleave', function() {
            this.style.transform = '';
            this.style.boxShadow = '';
        });
    });
}

// 表单提交处理
function initForms() {
    const forms = document.querySelectorAll('form');
    forms.forEach(form => {
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            const submitButton = this.querySelector('button[type="submit"]');
            const originalText = submitButton.innerHTML;

            // 简单表单验证
            let isValid = true;
            const requiredInputs = this.querySelectorAll('[required]');
            requiredInputs.forEach(input => {
                if (!input.value.trim()) {
                    isValid = false;
                    input.classList.add('invalid');
                    setTimeout(() => input.classList.remove('invalid'), 3000);
                }
            });

            if (!isValid) {
                alert('请填写所有必填字段');
                return;
            }

            // 显示加载状态
            submitButton.disabled = true;
            submitButton.innerHTML = '<span class="loading">提交中...</span>';

            // 使用Formspree API提交表单
            fetch(this.action, {
                method: this.method,
                body: new FormData(this),
                headers: {
                    'Accept': 'application/json'
                }
            })
            .then(response => {
                if (response.ok) {
                    alert('提交成功！我们将尽快与您联系。');
                    this.reset();
                } else {
                    response.json().then(data => {
                        alert('提交失败: ' + (data.errors ? data.errors.map(e => e.message).join(', ') : '未知错误'));
                    });
                }
            })
            .catch(error => {
                alert('网络错误，请稍后重试。');
            })
            .finally(() => {
                submitButton.disabled = false;
                submitButton.innerHTML = originalText;
            });
        });
    });
}

// 图片懒加载实现
function initLazyLoading() {
    if ('IntersectionObserver' in window) {
        const imageObserver = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const image = entry.target;
                    image.src = image.dataset.src;
                    image.classList.add('loaded');
                    imageObserver.unobserve(image);
                }
            });
        });

        document.querySelectorAll('img.lazyload').forEach(img => {
            imageObserver.observe(img);
        });
    } else {
        // 回退方案：立即加载所有图片
        document.querySelectorAll('img.lazyload').forEach(img => {
            img.src = img.dataset.src;
            img.classList.add('loaded');
        });
    }
}

// 页面加载完成后初始化所有功能
function initThemeSwitcher() {
    const toggle = document.getElementById('theme-toggle');
    if (!toggle) return;

    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    let isDark = localStorage.getItem('theme') === 'dark' || (localStorage.getItem('theme') === null && prefersDark);
    
    updateTheme(isDark);

    toggle.addEventListener('click', () => {
        isDark = !isDark;
        updateTheme(isDark);
        localStorage.setItem('theme', isDark ? 'dark' : 'light');
    });

    function updateTheme(isDark) {
        document.documentElement.setAttribute('data-theme', isDark ? 'dark' : 'light');
        const darkIcon = toggle.querySelector('.dark-icon');
        const lightIcon = toggle.querySelector('.light-icon');
        if (darkIcon && lightIcon) {
            darkIcon.style.display = isDark ? 'none' : 'block';
            lightIcon.style.display = isDark ? 'block' : 'none';
        }
    }
}

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', function() {
    // 等待组件加载完成
    Promise.all([
        loadComponent('site-header', 'components/header.html'),
        loadComponent('site-footer', 'components/footer.html')
    ]).then(() => {
        // 组件加载完成后初始化功能
        initThemeSwitcher();
        initMobileMenu();
        initAnnouncement();
        initWorkPreview();
        initForms();
        initLazyLoading();
        document.body.classList.add('page-loaded');
    });
});

// 加载组件的通用函数
function loadComponent(elementId, componentPath) {
    return fetch(componentPath)
        .then(response => response.text())
        .then(data => {
            const element = document.getElementById(elementId);
            if (element) {
                element.innerHTML = data;
            }
        })
        .catch(error => {
            console.error(`加载组件失败: ${componentPath}`, error);
        });
}