# There can only be a single job definition per file.
# Create a job with ID and Name 'example'
job "run-nifi" {
	# Run the job in the global region, which is the default.
	# region = "global"

	# Specify the datacenters within the region this job can run in.
	datacenters = ["aws"]

	# Service type jobs optimize for long-lived services. This is
	# the default but we can change to batch for short-lived tasks.
	type = "service"

	# Priority controls our access to resources and scheduling priority.
	# This can be 1 to 100, inclusively, and defaults to 50.
	# priority = 50



	# Create a 'cache' group. Each task in the group will be
	# scheduled onto the same machine.
	group "nifi" {
		# Control the number of instances of this group.
		# Defaults to 1
		count = 1


		# Define a task to run
		task "launch-nifi" {
			# Use Docker to run the task.
			driver = "docker"

			# Configure Docker driver with the image
			config {
                  image = "sunileman/nifi1.1.0"
                  port_map {
                    nifi = 8080
                  }
              }
			service {
				name = "${TASKGROUP}-service"
				tags = ["global", "niif"]
				port = "nifi"

        check {
            type     = "http"
            port     = "nifi"
            path     = "/"
            interval = "60s"
            timeout  = "60s"
            initial_status = "passing"
            }

			}

			# We must specify the resources required for
			# this task to ensure it runs on a machine with
			# enough capacity.
			resources {
				cpu = 100 # 500 MHz
				memory = 2000 # 128MB
				network {
					mbits = 1
					port "nifi" {
					}
				}
			}

			# Specify configuration related to log rotation
			logs {
			    max_files = 10
			    max_file_size = 15
			}

			# Controls the timeout between signalling a task it will be killed
			# and killing the task. If not set a default is used.
			kill_timeout = "10s"
		}
	}
}
