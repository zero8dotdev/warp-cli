use colored::Colorize;
use serde_json::json;

/// Format status output based on mode (JSON or human-readable)
pub fn output(json: bool, quiet: bool, message: impl AsRef<str>, data: Option<serde_json::Value>) {
    if quiet {
        return;
    }

    if json {
        if let Some(d) = data {
            println!("{}", d.to_string());
        } else {
            let obj = json!({ "message": message.as_ref() });
            println!("{}", obj.to_string());
        }
    } else {
        println!("{}", message.as_ref());
    }
}

/// Output success message
pub fn success(json: bool, quiet: bool, message: impl AsRef<str>) {
    if quiet {
        return;
    }

    if json {
        let obj = json!({ "status": "success", "message": message.as_ref() });
        println!("{}", obj.to_string());
    } else {
        println!("{}", message.as_ref().green());
    }
}

/// Output error message
pub fn error(message: impl AsRef<str>) {
    eprintln!("{}", message.as_ref().red());
}

/// Output warning message
pub fn warning(json: bool, quiet: bool, message: impl AsRef<str>) {
    if quiet {
        return;
    }

    if json {
        let obj = json!({ "status": "warning", "message": message.as_ref() });
        eprintln!("{}", obj.to_string());
    } else {
        eprintln!("{}", message.as_ref().yellow());
    }
}

/// Output info message
pub fn info(json: bool, quiet: bool, message: impl AsRef<str>) {
    if quiet {
        return;
    }

    if json {
        let obj = json!({ "status": "info", "message": message.as_ref() });
        println!("{}", obj.to_string());
    } else {
        println!("{}", message.as_ref().cyan());
    }
}
