output "shell_script" {
    value = data.template_file.user_data.rendered
}