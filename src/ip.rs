use anyhow::Result;

/// Get user's public IP address
pub fn get_public_ip() -> Result<String> {
    // Try to get IP from ipify API (fast, reliable, no auth needed)
    match get_ip_from_ipify() {
        Ok(ip) => Ok(ip),
        Err(_) => {
            // Fallback to ifconfig.me
            get_ip_from_ifconfig()
        }
    }
}

/// Get IP from ipify.org API
fn get_ip_from_ipify() -> Result<String> {
    let client = reqwest::blocking::Client::new();
    let response = client
        .get("https://api.ipify.org?format=text")
        .timeout(std::time::Duration::from_secs(5))
        .send()?;

    let ip = response.text()?.trim().to_string();

    if ip.is_empty() {
        anyhow::bail!("Empty IP response");
    }

    Ok(ip)
}

/// Get IP from ifconfig.me as fallback
fn get_ip_from_ifconfig() -> Result<String> {
    let client = reqwest::blocking::Client::new();
    let response = client
        .get("https://ifconfig.me")
        .timeout(std::time::Duration::from_secs(5))
        .send()?;

    let ip = response.text()?.trim().to_string();

    if ip.is_empty() {
        anyhow::bail!("Empty IP response");
    }

    Ok(ip)
}

/// Format IP address for display
pub fn format_ip(ip: &str) -> String {
    format!("IP: {}", ip)
}
