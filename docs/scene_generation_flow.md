# Scene Generation Flow

This diagram illustrates the sequence of jobs involved in generating a scene's content, outline, and summary.
See also the [Chapter Generation Flow](chapter_generation_flow.md) for how chapters are generated.

```mermaid
flowchart TD
    %% Outline Generation
    WriteScenesJob -->|generates for each scene| outline[(Scene: outline)]

    %% Content Generation Jobs
    WriteScenesJob -->|enqueues for each scene| WriteSceneContentJob
    
    %% Content Updates
    WriteSceneContentJob -->|generates| content[(Scene: content)]
    
    %% Summary Generation
    WriteSceneContentJob -->|on completion enqueues| WriteSceneSummaryJob
    WriteSceneSummaryJob -->|updates| summary[(Scene: summary)]
```
