# WARP for Agentic Development

This guide explores how Cloudflare WARP can enhance AI agent development, testing, and deployment.

---

## Why WARP Matters for Agents

AI agents often need to:
- **Make API calls** to external services
- **Test in different geographic regions**
- **Avoid rate limiting and IP bans**
- **Communicate securely** with other agents
- **Access region-restricted services**
- **Run reliably** under network constraints

WARP solves these challenges.

---

## Use Cases & Benefits

### 1. Geographic Location Testing

**Problem:** Your agent needs to work in different regions, but you're testing from one location.

**Solution:** Use WARP to change your apparent location
```bash
# Your agent connects through Cloudflare's network
# Appears to come from different geographic regions
# Test pricing, content, APIs that vary by location

warp up        # Connect (might appear as EU)
python agent.py
warp down

# Run again - might appear as US
# Test how agent behaves in different regions
```

**Real example:**
```python
import requests

# With WARP, this call appears from different IPs/regions
response = requests.get('https://api.service.com/price')
# Price might change based on detected location
```

### 2. API Rate Limiting & IP Ban Protection

**Problem:** Your agent makes many API calls and gets rate-limited or IP-banned.

**Solution:** WARP gives you a different IP address
```bash
# Simulate multiple agents with different IPs
for agent_id in {1..5}; do
    # Each agent appears from different IP via WARP
    warp up
    python agent.py --id $agent_id &
    sleep 2
    warp down
done
```

**Why it helps:**
- Cloudflare's IP reputation is better than typical ISPs
- Better chance of not hitting rate limits
- Rotate between different Cloudflare IPs

### 3. Secure Agent-to-Agent Communication

**Problem:** Multiple agents need to communicate securely over untrusted networks.

**Solution:** Route agent communication through WARP
```bash
# Agent A (on server 1)
warp up
python agent_a.py --role consumer

# Agent B (on server 2)
warp up
python agent_b.py --role producer

# Communication between them is encrypted via WARP
# Even if network is compromised, traffic is protected
```

**Architecture:**
```
Agent A ──┐
          ├─→ WARP Tunnel ──→ Agent B
Agent C ──┘

All communication encrypted, IP addresses hidden
```

### 4. Multi-Region Agent Deployment

**Problem:** Deploy agents in multiple regions but manage from single control plane.

**Solution:** WARP enables secure tunneling to agents
```bash
# Control plane (your laptop)
warp up

# Connect to agents in different regions
$ ssh agent@region1.internal   # Via WARP tunnel
$ ssh agent@region2.internal   # Via WARP tunnel

# All connections encrypted, no VPN setup per region
```

### 5. CI/CD Integration for Agent Testing

**Problem:** Test agents in CI/CD pipelines with different network conditions.

**Solution:** Automate WARP control in your CI workflow
```bash
#!/bin/bash
# .github/workflows/test-agents.yml

# Run agent tests from different "locations"
warp up
pytest tests/agent_tests.py --location=europe

warp down
sleep 5

warp up
pytest tests/agent_tests.py --location=asia

warp down
```

### 6. Malware & Tracker Filtering

**Problem:** Agent makes API calls to potentially unsafe endpoints.

**Solution:** WARP filters malware and trackers automatically
```python
import requests

# This call is filtered by WARP's network
# Malware sites are blocked
# Tracking pixels are filtered
response = requests.get('https://api.untrusted-source.com/data')

# Safer for agent security
```

### 7. Split Tunnel for Selective Routing

**Problem:** Agent needs to access some services locally, others via VPN.

**Solution:** Use split tunneling
```bash
# Route only certain domains through WARP
warp exclude add internal-company.com      # Use local network
warp exclude add internal-database.local   # Use local network

# Everything else goes through WARP
# Keeps local services fast, other traffic secure
```

### 8. Bypassing Network Restrictions

**Problem:** Agent is deployed in restricted network (corporate, school, ISP block).

**Solution:** WARP encrypts traffic so restrictions don't apply
```bash
warp up  # Bypasses DPI (Deep Packet Inspection)

# Agent can now access:
# - Geo-restricted APIs
# - Services blocked by ISP
# - Websites filtered by corporate firewall
```

---

## Implementation Patterns

### Pattern 1: Location-Aware Agent

```python
#!/usr/bin/env python3
"""Agent that adapts behavior based on detected location"""

import subprocess
import requests
from enum import Enum

class Region(Enum):
    US = "us"
    EU = "eu"
    ASIA = "asia"

class LocationAwareAgent:
    def __init__(self, region: Region):
        self.region = region
        self.connect_to_region()

    def connect_to_region(self):
        """Connect WARP to simulate region"""
        subprocess.run(["warp", "up"], check=True)
        # In real implementation, would rotate to specific region IP

    def check_service_availability(self, url: str) -> bool:
        """Check if service is available in this region"""
        try:
            response = requests.get(url, timeout=5)
            return response.status_code == 200
        except:
            return False

    def get_regional_pricing(self, product: str) -> float:
        """Get pricing for product in this region"""
        response = requests.get(
            f"https://api.example.com/pricing",
            params={"product": product, "region": self.region.value}
        )
        return response.json()["price"]

    def shutdown(self):
        """Clean up - disconnect WARP"""
        subprocess.run(["warp", "down"], check=True)

# Usage
if __name__ == "__main__":
    for region in Region:
        agent = LocationAwareAgent(region)
        price = agent.get_regional_pricing("premium-plan")
        print(f"{region.value}: ${price}")
        agent.shutdown()
```

### Pattern 2: Distributed Agent Network

```python
#!/usr/bin/env python3
"""Multiple agents communicating securely through WARP"""

import asyncio
import subprocess
from dataclasses import dataclass

@dataclass
class Agent:
    id: str
    role: str  # "producer", "consumer", "aggregator"

    async def startup(self):
        """Start WARP and agent process"""
        subprocess.run(["warp", "up"], check=True)
        print(f"Agent {self.id} connected via WARP")

    async def shutdown(self):
        """Stop agent and WARP"""
        subprocess.run(["warp", "down"], check=True)
        print(f"Agent {self.id} disconnected")

    async def send_message(self, recipient: str, message: dict):
        """Send message to another agent via WARP tunnel"""
        # All communication encrypted by WARP
        print(f"Agent {self.id} → {recipient}: {message}")

    async def run(self):
        """Agent main loop"""
        await self.startup()

        if self.role == "producer":
            # Produce data
            for i in range(10):
                await self.send_message(
                    "aggregator",
                    {"data": f"batch_{i}"}
                )
                await asyncio.sleep(1)

        await self.shutdown()

# Usage
async def main():
    agents = [
        Agent("producer-1", "producer"),
        Agent("producer-2", "producer"),
        Agent("aggregator-1", "aggregator"),
    ]

    await asyncio.gather(*[agent.run() for agent in agents])

asyncio.run(main())
```

### Pattern 3: Agent Testing Framework

```python
#!/usr/bin/env python3
"""Test framework for agents in different network conditions"""

import subprocess
import pytest
from contextlib import contextmanager

@contextmanager
def warp_connection():
    """Context manager for WARP connection during tests"""
    subprocess.run(["warp", "up"], check=True)
    try:
        yield
    finally:
        subprocess.run(["warp", "down"], check=True)

class TestAgentBehavior:
    """Test how agent behaves with/without WARP"""

    def test_agent_without_vpn(self):
        """Test agent using direct connection"""
        agent = MyAgent()
        result = agent.run()
        assert result.success
        assert result.latency < 1000  # Direct is fast

    def test_agent_with_vpn(self):
        """Test agent through WARP"""
        with warp_connection():
            agent = MyAgent()
            result = agent.run()
            assert result.success
            assert result.latency < 2000  # VPN adds latency

    def test_agent_location_handling(self):
        """Test agent handles location changes"""
        # This would rotate through different WARP endpoints
        locations = ["US", "EU", "Asia"]
        for location in locations:
            with warp_connection():
                agent = MyAgent()
                detected_location = agent.detect_location()
                # Verify behavior is region-appropriate
```

---

## Performance Considerations

### Latency Impact
- **Direct connection:** ~20-50ms
- **WARP connection:** ~50-150ms
- **Trade-off:** Security/privacy vs latency

### Throughput
- WARP handles high throughput well (>100 Mbps)
- Good for bulk API calls by agents

### Cost
- WARP is free (optional paid plans)
- No per-API-call charges
- Good for cost-sensitive agent deployments

---

## Best Practices

### 1. Enable Split Tunneling
```bash
# Don't route internal services through WARP
warp exclude add internal-api.local
warp exclude add localhost:5000
```

### 2. Monitor Agent Network Health
```bash
# Check connection status before agent starts
if warp status | grep -q "Connected"; then
    python agent.py
else
    echo "WARP not connected!"
    exit 1
fi
```

### 3. Graceful Shutdown
```bash
# Always disconnect cleanly
trap "warp down" EXIT
warp up
python agent.py
# Automatically runs "warp down" on exit
```

### 4. Test with and without WARP
```bash
# Verify agent works in both modes
for mode in "with_vpn" "without_vpn"; do
    if [ "$mode" = "with_vpn" ]; then
        warp up
    fi

    pytest tests/agent_tests.py --mode=$mode

    if [ "$mode" = "with_vpn" ]; then
        warp down
    fi
done
```

### 5. Rate Limiting Awareness
```python
# WARP provides better IP reputation, but still respect rate limits
import time
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

def create_session_with_retry():
    session = requests.Session()
    retry = Retry(
        total=3,
        backoff_factor=0.5,
        status_forcelist=[429, 503]  # Retry on rate limit
    )
    adapter = HTTPAdapter(max_retries=retry)
    session.mount("https://", adapter)
    return session

# Use with agent
agent.session = create_session_with_retry()
```

---

## Advanced Use Cases

### 1. A/B Testing Across Regions
Test different agent behaviors in different regions simultaneously:
```bash
# Agent variant A in US
warp up  # Connect as US
python agent.py --variant=A --region=us &

# Agent variant B in EU (different process with different WARP endpoint)
warp up  # Connect as EU
python agent.py --variant=B --region=eu &

# Compare performance metrics
```

### 2. Compliance & Data Residency
Keep agent traffic within specific regions:
```bash
# EU agent must stay in EU region
# Don't use WARP's global routing, use regional tunneling
warp up --region=eu
python agent.py --data_residency=eu
```

### 3. Load Testing
Simulate traffic from multiple agents with different IPs:
```bash
# Each run of agent appears from different IP
for i in {1..100}; do
    warp up
    python agent.py --id=$i &
    sleep 0.1
    warp down
done
```

### 4. Security Testing
Test agent behavior under network attacks:
```bash
# WARP provides DDoS protection and threat filtering
warp up  # Enable protection

# Agent makes requests - automatically filtered
# Malicious responses are blocked
python agent.py --test_security=true
```

---

## Common Questions

**Q: Will WARP slow down my agents?**
A: Yes, slightly (20-100ms added latency). Worth it for security/privacy. Profile your specific agents to measure impact.

**Q: Can I use WARP in production with agents?**
A: Absolutely. It's production-ready. Many use WARP for agent infrastructure security.

**Q: How do I rotate between different WARP IPs?**
A: WARP automatically uses different IPs from Cloudflare's pool. Disconnect/reconnect to get new IP: `warp down && sleep 2 && warp up`

**Q: Can agents be deployed with WARP in containers?**
A: Yes! Install WARP daemon in your container, then use warp-cli. See [Installation Guide](INSTALLATION.md).

**Q: Is there a performance penalty for split tunneling?**
A: Minimal. Split tunneling actually improves performance by keeping local traffic local.

---

## Integration with Agent Frameworks

### LangChain/LLM Agents
```python
from langchain.agents import AgentExecutor
import subprocess

# Setup
subprocess.run(["warp", "up"])

# Your agents inherit WARP protection
executor = AgentExecutor.from_agent_and_tools(...)
result = executor.run("Get data from multiple regions")

# Cleanup
subprocess.run(["warp", "down"])
```

### Multi-Agent Systems
```python
from multi_agent_framework import Agent, Network

# Create network with WARP
network = Network(use_warp=True)

agent1 = Agent("producer", network)
agent2 = Agent("consumer", network)

# All communication encrypted by WARP
network.start()
```

---

## Conclusion

WARP enables AI agents to:
- ✅ Test globally from anywhere
- ✅ Avoid rate limiting and IP bans
- ✅ Communicate securely
- ✅ Access region-restricted services
- ✅ Operate under network constraints
- ✅ Maintain infrastructure security

With **warp-cli**, controlling WARP from agent code is simple and scriptable.

---

## Next Steps

1. Try the [Pattern 1 example](AGENTIC_DEVELOPMENT.md#pattern-1-location-aware-agent) with your agent
2. Add WARP to your agent testing workflow
3. Monitor performance impact in your specific use case
4. Consider split tunneling for optimized routing

Questions? See [USAGE_EXAMPLES.md](USAGE_EXAMPLES.md) for more command examples.
