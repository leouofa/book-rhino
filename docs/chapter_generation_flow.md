# Chapter Generation Flow

This diagram illustrates the sequence of jobs involved in generating a chapter's content, outline, and summary.
See also the [Scene Generation Flow](scene_generation_flow.md) for how scenes within a chapter are generated.

```mermaid
flowchart TD
    %% Outline Generation
    GenerateBookPlotJob -->|generates| outline[(Chapter: outline)]

    %% Content Generation Jobs
    RenderBookJob -->|enqueues for each chapter| WriteChaptersJob
    WriteChaptersJob -->|enqueues for each chapter| WriteChapterContentJob
    RenderChapterJob -->|enqueues for a given chapter| WriteChapterContentJob
    
    %% Content Updates
    WriteChapterContentJob -->|generates| content[(Chapter: content)]
    
    %% Summary Generation
    WriteChapterContentJob -->|on completion enqueues| WriteChapterSummaryJob
    WriteChapterSummaryJob -->|updates| summary[(Chapter: summary)]
```
