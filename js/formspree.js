document.addEventListener('DOMContentLoaded', function () {
    // 表单提交处理函数
    function handleFormSubmit(event) {
        event.preventDefault();
        const form = event.target;
        const submitButton = form.querySelector('button[type="submit"]');
        const originalButtonText = submitButton.innerHTML;

        // 简单表单验证
        const requiredFields = form.querySelectorAll('[required]');
        let isValid = true;

        requiredFields.forEach(field => {
            if (!field.value.trim()) {
                isValid = false;
                field.classList.add('invalid');
                setTimeout(() => field.classList.remove('invalid'), 3000);
            }
        });

        if (!isValid) {
            alert('请填写所有必填字段');
            return;
        }

        // 显示加载状态
        submitButton.disabled = true;
        submitButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i> 提交中...';

        // 使用Formspree API提交表单
        fetch(form.action, {
            method: form.method,
            body: new FormData(form),
            headers: {
                'Accept': 'application/json'
            }
        })
            .then(response => {
                if (response.ok) {
                    alert('订单提交成功！我们将尽快与您联系。');
                    form.reset();
                } else {
                    response.json().then(data => {
                        if (data.errors) {
                            alert('提交失败: ' + data.errors.map(error => error.message).join(', '));
                        } else {
                            alert('提交失败，请稍后再试。');
                        }
                    });
                }
            })
            .catch(error => {
                alert('网络错误，请检查您的连接后重试。');
            })
            .finally(() => {
                // 恢复按钮状态
                submitButton.disabled = false;
                submitButton.innerHTML = originalButtonText;
            });
    }

    // 为所有表单添加提交事件监听器
    const forms = document.querySelectorAll('form[data-formspree]');
    forms.forEach(form => {
        form.addEventListener('submit', handleFormSubmit);
    });
});