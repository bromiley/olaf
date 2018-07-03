#!/usr/bin/env python3
# -*- coding: utf-8 -*-

class audit_properties:
    logon_type = {
        0 : "Mailbox Owner",
        1 : "Administrator",
        2 : "Delegate",
        3 : "MSFT Datacenter Transport Service",
        4 : "MSFT Datacenter Service Account",
        5 : "Delegated Administrator"
    }

    user_type = {
        0 : "Regular User",
        2 : "O365 Administrator",
        3 : "Datacenter administrator or system",
        4 : "System account",
        5 : "Application",
        6 : "Service principal"
    }
