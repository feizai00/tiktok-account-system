/**
 * TikTok账号管理系统 - 账号页面JavaScript
 */

document.addEventListener('DOMContentLoaded', function() {
    // 模态框操作
    const accountModal = document.getElementById('accountModal');
    const deleteModal = document.getElementById('deleteModal');
    const sellModal = document.getElementById('sellModal');
    const addAccountBtn = document.getElementById('addAccountBtn');
    const closeButtons = document.querySelectorAll('.close-btn');
    const cancelBtn = document.getElementById('cancelBtn');
    const cancelDeleteBtn = document.getElementById('cancelDeleteBtn');
    const cancelSellBtn = document.getElementById('cancelSellBtn');
    const accountForm = document.getElementById('accountForm');
    const modalTitle = document.getElementById('modalTitle');
    const accountId = document.getElementById('accountId');
    const statusFilter = document.getElementById('statusFilter');
    const searchInput = document.getElementById('searchInput');
    
    // 账号表格中的刷新按钮
    const refreshButtons = document.querySelectorAll('.refresh-btn');
    
    // 初始化页面
    initPage();
    
    /**
     * 初始化页面
     */
    function initPage() {
        // 打开添加账号模态框
        addAccountBtn.addEventListener('click', () => {
            modalTitle.textContent = '添加账号';
            accountId.value = '';
            accountForm.reset();
            accountModal.style.display = 'block';
            // 默认启用自动刷新，禁用数据字段
            toggleDataFieldsEditable();
        });
        
        // 关闭模态框
        closeButtons.forEach(btn => {
            btn.addEventListener('click', () => {
                accountModal.style.display = 'none';
                deleteModal.style.display = 'none';
                sellModal.style.display = 'none';
                // 重置表单状态
                resetFormState();
            });
        });
        
        cancelBtn.addEventListener('click', () => {
            accountModal.style.display = 'none';
            // 重置表单状态
            resetFormState();
        });
        
        cancelDeleteBtn.addEventListener('click', () => {
            deleteModal.style.display = 'none';
        });
        
        cancelSellBtn.addEventListener('click', () => {
            sellModal.style.display = 'none';
        });
        
        // 绑定所有事件
        bindEvents();
        
        // 自动刷新切换处理
        const autoRefreshCheckbox = document.getElementById('auto_refresh');
        if (autoRefreshCheckbox) {
            autoRefreshCheckbox.addEventListener('change', toggleDataFieldsEditable);
        }
        
        // 状态筛选
        statusFilter.addEventListener('change', () => {
            const status = statusFilter.value;
            const rows = document.querySelectorAll('.account-row');
            
            rows.forEach(row => {
                if (status === 'all' || row.classList.contains(status)) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        });
        
        // 搜索功能
        searchInput.addEventListener('input', () => {
            const searchText = searchInput.value.toLowerCase();
            const rows = document.querySelectorAll('.account-row');
            
            rows.forEach(row => {
                // 搜索所有字段
                const rowText = Array.from(row.cells).map(cell => cell.textContent.toLowerCase()).join(' ');
                if (rowText.includes(searchText)) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        });
        
        // 分页功能
        const prevBtn = document.querySelector('.prev-btn');
        const nextBtn = document.querySelector('.next-btn');
        const currentPage = document.getElementById('currentPage');
        
        prevBtn.addEventListener('click', () => {
            if (!prevBtn.disabled) {
                window.location.href = `/accounts?page=${parseInt(currentPage.textContent) - 1}`;
            }
        });
        
        nextBtn.addEventListener('click', () => {
            if (!nextBtn.disabled) {
                window.location.href = `/accounts?page=${parseInt(currentPage.textContent) + 1}`;
            }
        });
    }
    
    /**
     * 绑定所有事件
     */
    function bindEvents() {
        console.log('Binding events to buttons');
        // 点击查看按钮
        document.querySelectorAll('.view-btn').forEach(btn => {
            console.log('Found view button:', btn);
            btn.addEventListener('click', (e) => {
                const id = e.target.getAttribute('data-id');
                modalTitle.textContent = '查看账号';
                
                // 发送请求获取账号详情
                fetch(`/api/accounts/${id}`)
                    .then(response => response.json())
                    .then(account => {
                        accountId.value = id;
                        document.getElementById('username').value = account.username;
                        document.getElementById('price').value = account.price;
                        document.getElementById('status').value = account.status;
                        
                        // 填充必填的新字段
                        if (document.getElementById('password')) {
                            document.getElementById('password').value = account.password || '';
                        }
                        if (document.getElementById('contact')) {
                            document.getElementById('contact').value = account.contact || '';
                        }
                        
                        // 填充可选的新字段
                        if (document.getElementById('api_password')) {
                            document.getElementById('api_password').value = account.api_password || '';
                        }
                        if (document.getElementById('register_date')) {
                            document.getElementById('register_date').value = account.register_date || '';
                        }
                        if (document.getElementById('register_region')) {
                            document.getElementById('register_region').value = account.register_region || '';
                        }
                        if (document.getElementById('has_showcase')) {
                            document.getElementById('has_showcase').value = account.has_showcase || '无';
                        }
                        
                        // 填充API自动获取的字段
                        if (document.getElementById('total_views')) {
                            document.getElementById('total_views').value = account.total_views || 0;
                        }
                        if (document.getElementById('total_comments')) {
                            document.getElementById('total_comments').value = account.total_comments || 0;
                        }
                        if (document.getElementById('total_shares')) {
                            document.getElementById('total_shares').value = account.total_shares || 0;
                        }
                        if (document.getElementById('total_favorites')) {
                            document.getElementById('total_favorites').value = account.total_favorites || 0;
                        }
                        if (document.getElementById('region')) {
                            document.getElementById('region').value = account.region || '未知';
                        }
                        if (document.getElementById('account_type')) {
                            document.getElementById('account_type').value = account.account_type || '白号';
                        }
                        if (document.getElementById('followers')) {
                            document.getElementById('followers').value = account.followers || 0;
                        }
                        if (document.getElementById('likes')) {
                            document.getElementById('likes').value = account.likes || 0;
                        }
                        
                        // 设置所有字段为只读
                        const formInputs = accountForm.querySelectorAll('input, select');
                        formInputs.forEach(input => {
                            input.setAttribute('readonly', true);
                            if (input.tagName === 'SELECT') {
                                input.setAttribute('disabled', true);
                            }
                        });
                        
                        // 隐藏保存按钮，只显示取消按钮
                        document.getElementById('saveBtn').style.display = 'none';
                        
                        accountModal.style.display = 'block';
                        // 显示所有数据字段
                        document.getElementById('auto_refresh').checked = false;
                        toggleDataFieldsEditable();
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        alert('获取账号数据失败，请重试');
                    });
            });
        });
        
        // 点击编辑按钮
        document.querySelectorAll('.edit-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const id = e.target.getAttribute('data-id');
                modalTitle.textContent = '编辑账号';
                
                // 发送请求获取账号详情
                fetch(`/api/accounts/${id}`)
                    .then(response => response.json())
                    .then(account => {
                        accountId.value = id;
                        document.getElementById('username').value = account.username;
                        document.getElementById('price').value = account.price;
                        document.getElementById('status').value = account.status;
                        
                        // 填充必填的新字段
                        if (document.getElementById('password')) {
                            document.getElementById('password').value = account.password || '';
                        }
                        if (document.getElementById('contact')) {
                            document.getElementById('contact').value = account.contact || '';
                        }
                        
                        // 填充可选的新字段
                        if (document.getElementById('api_password')) {
                            document.getElementById('api_password').value = account.api_password || '';
                        }
                        if (document.getElementById('register_date')) {
                            document.getElementById('register_date').value = account.register_date || '';
                        }
                        if (document.getElementById('register_region')) {
                            document.getElementById('register_region').value = account.register_region || '';
                        }
                        if (document.getElementById('has_showcase')) {
                            document.getElementById('has_showcase').value = account.has_showcase || '无';
                        }
                        
                        // 填充API自动获取的字段
                        if (document.getElementById('total_views')) {
                            document.getElementById('total_views').value = account.total_views || 0;
                        }
                        if (document.getElementById('total_comments')) {
                            document.getElementById('total_comments').value = account.total_comments || 0;
                        }
                        if (document.getElementById('total_shares')) {
                            document.getElementById('total_shares').value = account.total_shares || 0;
                        }
                        if (document.getElementById('total_favorites')) {
                            document.getElementById('total_favorites').value = account.total_favorites || 0;
                        }
                        if (document.getElementById('region')) {
                            document.getElementById('region').value = account.region || '未知';
                        }
                        if (document.getElementById('account_type')) {
                            document.getElementById('account_type').value = account.account_type || '白号';
                        }
                        
                        accountModal.style.display = 'block';
                        // 默认启用自动刷新，禁用数据字段
                        toggleDataFieldsEditable();
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        alert('获取账号数据失败，请重试');
                    });
            });
        });
        
        // 点击删除按钮
        document.querySelectorAll('.delete-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const id = e.target.getAttribute('data-id');
                document.getElementById('confirmDeleteBtn').setAttribute('data-id', id);
                deleteModal.style.display = 'block';
            });
        });
        
        // 确认删除
        document.getElementById('confirmDeleteBtn').addEventListener('click', (e) => {
            const id = e.target.getAttribute('data-id');
            // 发送删除请求
            fetch(`/api/accounts/${id}`, {
                method: 'DELETE'
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // 删除成功，移除表格行
                    document.querySelector(`tr[data-id="${id}"]`).remove();
                    deleteModal.style.display = 'none';
                } else {
                    alert('删除失败：' + data.message);
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('删除失败，请重试');
            });
        });
        
        // 点击出售按钮
        document.querySelectorAll('.sell-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const id = e.target.getAttribute('data-id');
                const row = document.querySelector(`tr[data-id="${id}"]`);
                const price = row.cells[4].textContent.replace(/[¥,]/g, '');
                
                document.getElementById('sellAccountId').value = id;
                document.getElementById('sellAmount').value = price;
                sellModal.style.display = 'block';
            });
        });
        
        // 确认出售
        document.getElementById('sellForm').addEventListener('submit', (e) => {
            e.preventDefault();
            const id = document.getElementById('sellAccountId').value;
            const amount = document.getElementById('sellAmount').value;
            
            // 发送出售请求
            fetch('/api/transactions', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    account_id: id,
                    amount: amount
                })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // 出售成功，更新表格行
                    const row = document.querySelector(`tr[data-id="${id}"]`);
                    row.classList.remove('未售');
                    row.classList.add('已售');
                    row.cells[5].innerHTML = '<span class="status-badge 已售">已售</span>';
                    row.cells[7].innerHTML = `
                        <button class="action-btn edit-btn" data-id="${id}">编辑</button>
                        <button class="action-btn delete-btn" data-id="${id}">删除</button>
                    `;
                    sellModal.style.display = 'none';
                    
                    // 重新绑定事件
                    bindEvents();
                } else {
                    alert('出售失败：' + data.message);
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('出售失败，请重试');
            });
        });
        
        // 刷新账号数据
        document.querySelectorAll('.refresh-btn').forEach(button => {
            button.addEventListener('click', (e) => {
                e.preventDefault();
                const id = button.getAttribute('data-id');
                const row = button.closest('tr');
                
                // 显示加载状态
                button.textContent = '加载中...';
                button.disabled = true;
                
                // 调用刷新API
                fetch(`/api/accounts/${id}/refresh`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    }
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        // 更新表格行中的数据
                        const account = data.account;
                        row.cells[2].textContent = new Intl.NumberFormat().format(account.followers);
                        row.cells[3].textContent = new Intl.NumberFormat().format(account.likes);
                        row.cells[4].textContent = new Intl.NumberFormat().format(account.total_views);
                        row.cells[5].textContent = new Intl.NumberFormat().format(account.total_comments);
                        row.cells[6].textContent = new Intl.NumberFormat().format(account.total_shares);
                        row.cells[7].textContent = new Intl.NumberFormat().format(account.total_favorites);
                        row.cells[8].textContent = account.region || '未知';
                        row.cells[9].textContent = account.account_type || '普通账号';
                        
                        // 恢复按钮状态
                        button.textContent = '刷新';
                        button.disabled = false;
                        
                        // 显示成功消息
                        alert('账号数据已成功刷新！');
                    } else {
                        alert('刷新失败：' + data.message);
                        button.textContent = '刷新';
                        button.disabled = false;
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('刷新失败，请重试');
                    button.textContent = '刷新';
                    button.disabled = false;
                });
            });
        });
    }
    
    /**
     * 保存账号表单提交处理
     */
    accountForm.addEventListener('submit', (e) => {
        e.preventDefault();
        const id = accountId.value;
        const autoRefresh = document.getElementById('auto_refresh').checked;
        
        // 基本信息始终需要提供
        const formData = {
            username: document.getElementById('username').value,
            password: document.getElementById('password').value,
            contact: document.getElementById('contact').value,
            price: parseFloat(document.getElementById('price').value),
            status: document.getElementById('status').value,
            auto_refresh: autoRefresh
        };
        
        // 添加可选字段
        if (document.getElementById('api_password')) {
            formData.api_password = document.getElementById('api_password').value;
        }
        if (document.getElementById('register_date')) {
            formData.register_date = document.getElementById('register_date').value;
        }
        if (document.getElementById('register_region')) {
            formData.register_region = document.getElementById('register_region').value;
        }
        if (document.getElementById('has_showcase')) {
            formData.has_showcase = document.getElementById('has_showcase').value;
        }
        
        // 添加账号类型和辈分字段，这些字段不受自动刷新影响
        if (document.getElementById('account_type')) {
            formData.account_type = document.getElementById('account_type').value;
        }
        if (document.getElementById('generation_type')) {
            formData.generation_type = document.getElementById('generation_type').value;
        }
        
        // 如果没有选择自动刷新，添加所有字段
        if (!autoRefresh) {
            formData.followers = parseInt(document.getElementById('followers').value);
            formData.likes = parseInt(document.getElementById('likes').value);
            
            // 添加新字段
            if (document.getElementById('total_views')) {
                formData.total_views = parseInt(document.getElementById('total_views').value) || 0;
            }
            if (document.getElementById('total_comments')) {
                formData.total_comments = parseInt(document.getElementById('total_comments').value) || 0;
            }
            if (document.getElementById('total_shares')) {
                formData.total_shares = parseInt(document.getElementById('total_shares').value) || 0;
            }
            if (document.getElementById('total_favorites')) {
                formData.total_favorites = parseInt(document.getElementById('total_favorites').value) || 0;
            }
            if (document.getElementById('region')) {
                formData.region = document.getElementById('region').value;
            }
        }
        
        const method = id ? 'PUT' : 'POST';
        const url = id ? `/api/accounts/${id}` : '/api/accounts';
        
        fetch(url, {
            method: method,
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(formData)
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // 保存成功，刷新页面
                window.location.reload();
            } else {
                alert('保存失败：' + data.message);
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('保存失败，请重试');
        });
    });
    
    /**
     * 切换数据字段的显示与隐藏
     */
    function toggleDataFieldsEditable() {
        const autoRefresh = document.getElementById('auto_refresh').checked;
        const manualDataFields = document.getElementById('manual-data-fields');
        
        // 如果选中了自动刷新，隐藏手动数据字段
        // 否则显示手动数据字段
        if (manualDataFields) {
            manualDataFields.style.display = autoRefresh ? 'none' : 'block';
        }
    }
    
    /**
     * 重置表单状态
     */
    function resetFormState() {
        // 移除所有只读属性
        const formInputs = accountForm.querySelectorAll('input, select');
        formInputs.forEach(input => {
            input.removeAttribute('readonly');
            if (input.tagName === 'SELECT') {
                input.removeAttribute('disabled');
            }
        });
        
        // 显示保存按钮
        if (document.getElementById('saveBtn')) {
            document.getElementById('saveBtn').style.display = 'inline-block';
        }
    }
});
