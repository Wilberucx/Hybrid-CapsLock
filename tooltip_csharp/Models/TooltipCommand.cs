using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace TooltipApp.Models
{
    public class TooltipCommand
    {
        [JsonPropertyName("tooltip_type")]
        public string TooltipType { get; set; } = "leader";
        
        [JsonPropertyName("title")]
        public string Title { get; set; } = "";
        
        [JsonPropertyName("items")]
        public List<TooltipItem> Items { get; set; } = new();
        
        [JsonPropertyName("navigation")]
        public List<string> Navigation { get; set; } = new();
        
        [JsonPropertyName("timeout_ms")]
        public int TimeoutMs { get; set; } = 7000;
        
        [JsonPropertyName("show")]
        public bool Show { get; set; } = false;
    }

    public class TooltipItem
    {
        [JsonPropertyName("key")]
        public string Key { get; set; } = "";
        
        [JsonPropertyName("description")]
        public string Description { get; set; } = "";
    }
}