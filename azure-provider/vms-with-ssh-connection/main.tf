resource "azurerm_resource_group" "test-rg" {
  name     = "test-rg"
  location = "EAST US"
}

resource "azurerm_virtual_network" "vnet-test" {
  name                = "vnet-test"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test-rg.location
  resource_group_name = azurerm_resource_group.test-rg.name
}

resource "azurerm_subnet" "subnet-test" {
  name                 = "subnet-test"
  resource_group_name  = azurerm_resource_group.test-rg.name
  virtual_network_name = azurerm_virtual_network.vnet-test.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "public-ip" {
  name = "public-ip"
  resource_group_name = azurerm_resource_group.test-rg.name
  location = azurerm_resource_group.test-rg.location
  allocation_method = "Static"

  tags = {
      environment = "test"
  }
}

resource "azurerm_network_interface" "netw-interf" {
  name                = "netw-interf"
  location            = azurerm_resource_group.test-rg.location
  resource_group_name = azurerm_resource_group.test-rg.name

  ip_configuration {
    name                          = "testconfig"
    subnet_id                     = azurerm_subnet.subnet-test.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public-ip.id
  }
}

resource "azurerm_virtual_machine" "bastion" {

  name                  = "bastionvm"
  location              = azurerm_resource_group.test-rg.location
  resource_group_name   = azurerm_resource_group.test-rg.name
  network_interface_ids = [azurerm_network_interface.netw-interf.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  delete_data_disks_on_termination = true

  delete_os_disk_on_termination = true

  storage_os_disk {
    name              = "bastionosdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "bastion"
    admin_username = "ops"
    admin_password = "c1oudc0w!"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/ops/.ssh/authorized_keys"
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }

  tags = {
    name        = "bastion"
    role        = "bastion"
    environment = "staging"
  }

}
