# ansible 模块开发

1. 修改 ansible.cfg 添加自定义模块位置
2. 编写自定义模块


```
#!/usr/bin/env python

import commands
from ansible.module_utils.basic import AnsibleModule

def run_module():
    module_args = dict(
        name=dict(type='str', required=True),
        new=dict(type='bool', required=False, default=False)
    )

    result = dict(
        changed=False,
        original_message='',
        message=''
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    if module.check_mode:
        module.exit_json(**result)

    status,output = commands.getstatusoutput('''date +%z''')
    result['original_message'] = module.params['name']
    result['message'] = output

    if module.params['new']:
        result['changed'] = True

    if module.params['name'] == 'fail me':
        module.fail_json(msg='You requested this to fail', **result)

    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()
```



# 参考

* https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general.html
