
data "null_data_source" "consul" {
    inputs = {
        instance_name = "${coalesce(
                var.tagName,
                join("-", list("consul", var.project_tag))
            )}"
    }
}
