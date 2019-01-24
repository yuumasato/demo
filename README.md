# ComplianceAsCode/content workshop


This repository features support files and examples to support going through a ComplianceAsCode/content tutorial.

## Setup before the workshop

We recommend attendees of the workshop to prepare a few things before the workshop.\
Internet connection may be limited so we kindly ask you to:
- Clone the following repositories:
  - `git clone https://github.com/ComplianceAsCode/demo.git`
  - `git clone https://github.com/ComplianceAsCode/content.git`
- [Install and setup Test Suite VM](#Install-the-test-VM)

## Test Suite VM

ComplianceAsCode/content project features a Test Suite to test rule remediation and check.\
For detailed info check https://github.com/ComplianceAsCode/content/tree/master/tests.

### Install the test VM

Go to ComplianceAsCode/content `tests` directory, and run the `install_vm.py` script.
For the demo we recommend using a Fedora virtual machine.
```
$ install_vm.py ./install_vm.py --distro fedora --domain test-suite-fedora
```

The command above will create the VM in the user instance of libvirtd.\
After instalation finishes you will have to reconfigure the NIC of the machine to be able to SSH into it.\
Check what is the name of the virtual bridge interface provided by libvirt, `ip addr | grep virbr`.\
It will very likely be `virbr0`, edit the hardware settings of your VM:
-  change the source of NIC to "Specify sahred device name", and 
- set "Bridge name" to your virtual bridge interface (e.g., `virbr0`).

![Edit VM NIC](/images/libvirt_nic_bridge.png)

If you run the install script as root, the VM will be created in the system instance of libvirtd.\
You won't need to reconfigure the NIC, but every time you run the Test Suite, privileges will be required (i.e., type the root password).

Note: the root password of the VM is "server".

### Configure SSH connection

The Test Suite connects to the VM via SSH.\
To avoid typing the password for every connection made, let's configure SSH key authentication.

If you don't have an SSH key to use, generate one:\
`ssh-keygen -f ~/.ssh/test-suite-fedora_rsa -N ""`

Copy the public key to the VM:
```
ssh-copy -i ~/.ssh/test-suite-fedora_rsa.pub root@<ip>
```

Add an entry for the VM in ~/.ssh/config.
```
host <ip>
    IdentityFile ~/.ssh/test-suite-fedora_rsa
    User root
```

### Save the state of VM

Create a snapshot of the VM so that you can revert manually if anything goes wrong and the Test Suite cannot revert automatically.
