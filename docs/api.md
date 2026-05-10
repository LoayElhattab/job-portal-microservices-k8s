# API Contract

All public APIs are exposed through the gateway under `/api/v1`.

## Response Envelope

Success responses use:

```json
{
  "success": true,
  "data": {},
  "meta": {}
}
```

Error responses use:

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message"
  }
}
```

`meta` is optional and is used for pagination or list metadata.

## Authentication

| Method | Path | Auth | Role | Description |
| --- | --- | --- | --- | --- |
| `POST` | `/api/v1/users/register` | No | Any | Register a user with role `seeker` or `employer`. |
| `POST` | `/api/v1/users/login` | No | Any | Authenticate and receive a JWT. |
| `GET` | `/api/v1/users/profile` | Bearer JWT | `seeker` or `employer` | Return the current user's profile. |

JWT payloads include `userId`, `email`, and `role`. All services validate the same shared `JWT_SECRET`.

## Jobs

| Method | Path | Auth | Role | Description |
| --- | --- | --- | --- | --- |
| `POST` | `/api/v1/jobs` | Bearer JWT | `employer` | Create a job. |
| `GET` | `/api/v1/jobs` | No | Any | List jobs with optional `search`, `location`, `page`, and `limit` query params. |
| `GET` | `/api/v1/jobs/:id` | No | Any | Get one job by UUID. |
| `PATCH` | `/api/v1/jobs/:id` | Bearer JWT | Owning `employer` | Update a job. |
| `DELETE` | `/api/v1/jobs/:id` | Bearer JWT | Owning `employer` | Delete a job. |

Job records use UUID identifiers and store `employer_id` as the owning user UUID.

## Applications

| Method | Path | Auth | Role | Description |
| --- | --- | --- | --- | --- |
| `POST` | `/api/v1/applications` | Bearer JWT | `seeker` | Apply for a job. |
| `GET` | `/api/v1/applications` | Bearer JWT | `seeker` or `employer` | Seekers see their own applications; employers see applications for their jobs. |
| `PATCH` | `/api/v1/applications/:id/status` | Bearer JWT | Owning `employer` | Update application status. |

Application IDs, `job_id`, `seeker_id`, and `employer_id` are UUIDs. A unique constraint prevents the same seeker from applying to the same job more than once.

Application events are published to RabbitMQ:

| Action | Exchange | Routing key | Consumer effect |
| --- | --- | --- | --- |
| New application | `application_events` | `application.submitted` | Notify the employer. |
| Status update | `application_events` | `application.status_changed` | Notify the seeker. |

## Notifications

| Method | Path | Auth | Role | Description |
| --- | --- | --- | --- | --- |
| `GET` | `/api/v1/notifications` | Bearer JWT | `seeker` or `employer` | List current user's notifications. |

Supported query parameters:

| Parameter | Default | Description |
| --- | --- | --- |
| `page` | `1` | Page number. |
| `limit` | `10` | Page size. |

Notifications are created asynchronously by `notification-service` when it consumes RabbitMQ application events.

