# Data Processing Addendum

**Effective date:** May 14, 2026

This Data Processing Addendum ("DPA") supplements the [Privacy Policy](PRIVACY.md) of Applied Poetics ("Processor") and governs the processing of personal data by Processor when acting on behalf of a Controller, as defined by applicable data protection law, including the EU General Data Protection Regulation (GDPR).

This DPA applies only when the Controller (e.g., an enterprise customer, institution, or organization) explicitly enters into a written agreement with Processor that references this DPA.

## 1. Definitions

- **"Controller"** means the entity that determines the purposes and means of processing personal data.
- **"Processor"** means Applied Poetics, which processes personal data on behalf of the Controller.
- **"Personal Data"** means any information relating to an identified or identifiable natural person that is submitted to the Service by or on behalf of the Controller.
- **"Service"** means the Applied Poetics API and MCP server available at `https://api.appliedpoetics.org`.
- **"Sub-processor"** means any third party engaged by Processor to process Personal Data.

## 2. Scope and Purpose of Processing

Processor processes Personal Data submitted through the Service solely to:
- Perform literary, linguistic, numerical, and topical text analysis as requested by the Controller or the Controller's end users.
- Return the results of such analysis to the requesting party.

Processor does **not** use Personal Data for any other purpose, including training machine-learning models, advertising, profiling, or analytics beyond operational monitoring.

## 3. Nature of Processing

- **Ephemeral processing:** All text inputs, including any Personal Data contained therein, are held in volatile memory only for the duration of a single request. They are not written to disk, stored in a database, or retained after the response is returned.
- **No persistent storage:** Processor does not maintain archives, backups, or logs of submitted text.
- **Server logs:** Standard HTTP request metadata (timestamps, paths, status codes, IP addresses) may be retained for up to 30 days for security and operational monitoring. These logs do not include the body of submitted text.

## 4. Sub-processors

Processor does **not** engage Sub-processors for the processing of Personal Data. All processing occurs on infrastructure directly controlled by Processor. If Processor intends to engage a Sub-processor in the future, it will provide the Controller with prior notice and an opportunity to object.

## 5. Data Subject Rights

Because Processor does not retain submitted text, it cannot fulfill direct requests from data subjects to access, correct, or delete specific text inputs. The Controller remains responsible for:
- Receiving and responding to data subject requests.
- Ensuring that its own systems and records enable it to comply with such requests.

Processor will, upon reasonable request, provide the Controller with information necessary to demonstrate compliance with this DPA.

## 6. Security Measures

Processor implements the following technical and organizational measures:
- **Encryption in transit:** All API and MCP traffic is transmitted over TLS 1.2 or higher (HTTPS).
- **No authentication required:** The Service is publicly accessible; Controllers are responsible for ensuring their end users do not submit sensitive Personal Data or credentials.
- **Read-only operations:** Service tools analyze or transform text but do not write to external systems or data stores on behalf of the user.
- **Access controls:** Server infrastructure is accessible only to authorized personnel.
- **Monitoring:** Server logs are reviewed for anomalies and abuse.

## 7. Confidentiality

Processor personnel with access to Personal Data are subject to confidentiality obligations.

## 8. Audit and Inspection

Processor will make available to the Controller, upon reasonable written request and subject to appropriate confidentiality obligations, information necessary to demonstrate compliance with this DPA. Given the ephemeral nature of processing, audits will focus on:
- System architecture and configuration reviews.
- Access to infrastructure and logs.
- Confirmation that text inputs are not persistently stored.

## 9. Return and Deletion of Data

Because submitted text is not retained, there is no data to return upon termination. Processor will:
- Continue to delete text inputs immediately after processing.
- Delete or anonymize server logs in accordance with the retention schedule set forth in the Privacy Policy (no more than 30 days).

## 10. Data Transfers

Processor's servers are located in the United States. If the Controller is subject to GDPR and Personal Data is transferred from the European Economic Area (EEA) to the United States, the parties agree that such transfers are governed by the EU Standard Contractual Clauses (SCCs) for the transfer of personal data to third countries, which are incorporated by reference into this DPA. Given the ephemeral nature of processing and the absence of persistent storage, the risk associated with such transfers is minimized.

## 11. Liability and Indemnification

Each party's liability under this DPA is subject to the limitations and exclusions set forth in the underlying agreement between the parties (if any). Nothing in this DPA limits either party's liability for breaches of data protection law where such liability cannot be excluded by agreement.

## 12. Term and Termination

This DPA is effective as of the date the Controller and Processor enter into a written agreement that references it. It terminates automatically when the underlying agreement terminates or when the Controller ceases to use the Service.

## 13. Governing Law

This DPA is governed by the laws of the State of Pennsylvania, United States, without regard to conflict of law principles. To the extent required by GDPR, the EU Standard Contractual Clauses take precedence over any conflicting provisions.

## 14. Contact

For questions regarding this DPA or data protection matters:

- **Email:** dluman@allegheny.edu
- **Organization:** Applied Poetics
- **Website:** https://appliedpoetics.org

---

*This DPA is provided for future enterprise and institutional relationships. Public, unauthenticated use of the Service is governed solely by the [Privacy Policy](PRIVACY.md).*
