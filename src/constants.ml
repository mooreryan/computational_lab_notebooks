open! Core

let actions_dirname = ".actions"
let pending_actions_dir = Filename.concat actions_dirname "pending"
let completed_actions_dir = Filename.concat actions_dirname "completed"
let failed_actions_dir = Filename.concat actions_dirname "failed"
let ignored_actions_dir = Filename.concat actions_dirname "ignored"

let action_suffix = "sh"
let template_suffix = "gc_template.txt"
