documentation_complete: true

title: 'Travel Configuration'

description: |-
    This profile checks basic settings on machines going out for a trip.

selections:
    - sshd_disable_root_login
    - var_accounts_password_minlen_login_defs=10
    - accounts_password_minlen_login_defs
    - enterprise_app_mode_travel
