# Workshop hints

## Build the security content

The ComplianceAsCode/content project uses `cmake` build system.
The build itself is based on Python, `oscap`, and XSLT transforms.

To build the content, take the following steps:

1. Go to the `build` directory.
1. If it is the first build, or you are not exactly sure what were the last changes since the last build, re-run `cmake` by executing `cmake ..`.
   You don't have to re-run `cmake` if you make changes to the content that don't change relationship between files of the project.
1. Run `make <product>` to build the content you are interested in, e.g. `make fedora`. Running `make` without arguments will build content for all products that are available, which takes a lot of time.
1. After the build finishes, feel free to explore the built content.
1. Want to be more sure about changes you have just made? Run `make check`, which triggers the sanity-level test suite.


## Create a custom security policy

To create a custom policy, you have to know the "product" the policy applies to.
Typically, the product is a Linux distribution that maps to a top-level direcory of the ComplianceAsCode/content repository.

1. Locate your product. (Let's assume that it is Fedora.)
1. Navigate to the `profiles` folder of the product. All files with the `.profile` suffix are YAML files defining profiles (a.k.a. security policies).
1. Create a new `.profile` file. Either let yourself be inspired by existing profiles, or create one from scratch. You care about these keys:

```
# If not true, the profile is ignored
documentation_complete: true

title: 'The profile title displayed in description. Name of the profile is given by the filename of the .profile file'

description: |-
    More elaborate description of the profile

selections:
    - Rule_id_1
    - Rule_id_2
```

## Find a rule you are interested in

There is over a thousand of unique rules in ComplianceAsCode/content - it may be that if you are implementing your custom security policy, the rule is already in there.
Here are some tips that could help you not to reinvent the wheel:

* Grouping: Rules are organized in a tree hierarchy that can lead you towards a rule you want to use.
  For example, you can find the rule that bans `ssh root` login in `services -> ssh -> ssh_server -> sshd_disable_root_login`. Makes sense, right?
* Keyword analysis: You may use the `grep` utility to perform keyword analysis of rule definition files. For example, you can use the following command to search for root-related rules and narrow them to ssh-related by this command:
  `grep -Rli --include rule.yml root | grep sshd`


## Create a new rule

There is not a rule that you need in the upstream content?
No problem, you can create a new one, add it to a security policy, build it, and use it!
You have to find a group under the `linux_os/guide` directory where the rule fits.
It is perfectly fine to create a new group - every non-rule subdirectory of the `guide` directory contains a `group.yml` file with these keys:

```
# If not true, the group file is ignored
documentation_complete: true

title: 'My Group'

description: |-
    This group aggregates rules specific to my unique
    security policy.
```

Then, you create a directory that will define the rule's ID with optional files and subdirectories:

* `rule.yml`: The rule definition.
* `check/shared.xml` or `check/<product>.xml`: OVAL definitions that check whether the rule is satisfied. The `shared` basename indicates that it applies to all products, whereas you can have one or more specific `.xml` names for individual products.
* `bash/shared.sh` or product-specific `.sh`: Bash remediation, i.e. a script that makes the incompliant system compliant, and that ideally doesn't modify a system that is compliant already (i.e. the script is idempotent).
* `ansible/shared.yml` or product-specific `.yml`: Ansible task, i.e. a snippet that makes the incompliant system compliant. Typical Ansible tasks are idempotent by design.


## Testing a profile

For that, you need either VM or a container that you can connect to as root with SSH without having to manually enter a password.
Here, we describe a VM-based test - you therefore need a libvirt-based Fedora VM.
Go to the `tests` subdirectory and execute the `test_suite.py` script.

You need to specify the VM parameters, datastream parameters, and of course the profile you want to test.
For example:

```
python3 test_suite.py profile --datastream ../build/ssg-fedora-ds.xml --libvirt qemu:///session my_fedora_vm --xccdf-id scap_org.open-scap_cref_ssg-fedora-xccdf-1.2.xml travel
```

where these options are likely to apply to everybody:

* `../build/ssg-fedora-ds.xml` is path to the datastream. The component we are interested in has an internal ID of `scap_org.open-scap_cref_ssg-fedora-xccdf-1.2.xml`.
  There may be multiple components of the datastream, so we need to specify this, but this is valid for Fedora datastreams produced by the ComplianceAsCode/content project.
* `qemu:///session` is the libvirt backend, and you are liekly to use that one depending on how have you created the VM.
  The alternative backend may be `qemu:///system`.

these may differ:

* `my_fedora_vm` is name (a.k.a. domain) of the VM.
* `travel` is name of the profile to test.

Results of the test are displayed to the console, but if you open the test log directory, you will be able to find nice profile scanning reports.

There will be an initial scan, a scan coupled with execution of remediation scripts, and finally a final scan, i.e. scan after remediation.
Although the initial scan may exhibit multiple failiures, the final scan should have rules that have remediations fixed.


## Testing a rule

This is similar to testing a profile.
However, testing a rule is more complex - the test suite executes tests of rules whose ID match the given string, and a rule may be tested under multiple scenarios.

The typical command looks like this:

```
python3 test_suite.py rule --datastream ../build/ssg-fedora-ds.xml --libvirt qemu:///session my_fedora_vm --xccdf-id scap_org.open-scap_cref_ssg-fedora-xccdf-1.2.xml --dontclean my_rule_id
```

The `--donclean` option keeps HTML reports for each scenario in the test log directory.
You can also use the `--debug` option to pause the test execution whenever a scenario fails unexpectedly, so you can go to the VM and see for yourself what's going on.
