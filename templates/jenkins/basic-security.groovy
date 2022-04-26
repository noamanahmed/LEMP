#!groovy

import jenkins.model.*
import hudson.security.*
import jenkins.install.*;

def instance = Jenkins.getInstance()
instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)

def hudsonRealm = new HudsonPrivateSecurityRealm(false)

hudsonRealm.createAccount("{{username}}","{{password}}")
instance.setSecurityRealm(hudsonRealm)
instance.save()