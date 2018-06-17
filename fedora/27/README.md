## Requirements

`sudo apt-get install yum yum-utils`

`sudo cp repos/fedora*.repo /etc/yum/repos.d`
```
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/deployment_guide/sec-Using_Yum_Variables
```
says $releasevar is defined in yum.conf, its not - doesnt work, line below is meaningless, but its what i got.
`sudo cp repos/yum.conf /etc/yum/yum.conf`

defines the release version number, here we have hardcoded 27
`sudo cp repos/vars/releasevar /etc/yum/vars/releasevar`
