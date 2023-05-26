
import os
import re

def read_docker_compose_files():
    base_file_path = r'C:\git\iCREF-Architecture\docker-compose.yml'
    override_file_path = r'C:\git\iCREF-Architecture\docker-compose.override.yml'

    # Read base Docker Compose file
    with open(base_file_path, 'r') as base_file:
        base_content = base_file.read()

    # Read override Docker Compose file if it exists
    override_content = ''
    if os.path.isfile(override_file_path):
        with open(override_file_path, 'r') as override_file:
            override_content = override_file.read()

    return base_content, override_content

def write_docker_compose_files(base_content, override_content):
    base_file_path = r'C:\git\iCREF-Architecture\docker-compose.yml'
    override_file_path = r'C:\git\iCREF-Architecture\docker-compose.override.yml'

    # Write base Docker Compose file
    with open(base_file_path, 'w') as base_file:
        base_file.write(base_content)

    # Write override Docker Compose file
    with open(override_file_path, 'w') as override_file:
        override_file.write(override_content)

def enable_disable_services():
    base_content, override_content = read_docker_compose_files()

    # Extract service names from the files
    service_names = re.findall(r'service\s*:\s*([^\s]+)', base_content)

    # Prompt the user for service enable/disable choices
    print("Services:")
    for index, service_name in enumerate(service_names):
        print(f"{index + 1}. {service_name}")

    enabled_services = []
    disabled_services = []

    while True:
        choice = input("Enter the service number to enable/disable (0 to finish): ")
        if choice == '0':
            break

        try:
            choice = int(choice)
            if 1 <= choice <= len(service_names):
                service_name = service_names[choice - 1]
                enable = input(f"Enable {service_name}? (y/n): ")
                if enable.lower() == 'y':
                    enabled_services.append(service_name)
                else:
                    disabled_services.append(service_name)
            else:
                print("Invalid service number. Please try again.")
        except ValueError:
            print("Invalid input. Please enter a number.")

    # Modify the Docker Compose files
    for service_name in service_names:
        # Determine if the service should be enabled or disabled
        enabled = service_name in enabled_services

        # Comment out the service in the base Docker Compose file
        if enabled:
            base_content = re.sub(r'(?<=service\s*:\s*' + service_name + r')', '', base_content)
        else:
            base_content = re.sub(r'(?<=service\s*:\s*' + service_name + r')', '#', base_content)

        # Comment out the service in the override Docker Compose file
        if enabled:
            override_content = re.sub(r'(?<=service\s*:\s*' + service_name + r')', '', override_content)
        else:
            override_content = re.sub(r'(?<=service\s*:\s*' + service_name + r')', '#', override_content)

    write_docker_compose_files(base_content, override_content)
    print("Docker Compose files have been updated.")


enable_disable_services()
