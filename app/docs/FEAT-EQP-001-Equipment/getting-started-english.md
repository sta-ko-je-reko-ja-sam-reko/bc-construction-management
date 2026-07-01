# FEAT-EQP-001 - Equipment & Plant

Register your machines, vehicles and tools, set their rates, record usage against projects, and keep meter and maintenance logs. Requires the **Equipment & Plant** module.

## Steps

### 1. Set up numbering (one-time)

1. Open **Equipment Setup**.
2. In **Equipment Nos.**, choose the number series used to number new equipment.

### 2. Register equipment

1. Open the **Equipment** list and choose **New** to open the Equipment Card.
2. Leave **No.** blank to take the next number from the series, or type your own.
3. Enter **Description**, choose the **Equipment Type** (Machine / Vehicle / Tool / Other) and **Ownership** (Owned / Hired).
4. In **Resource No.**, link the standard resource the equipment posts cost and usage through. This is required before you can post usage.
5. Optionally fill **Location Code**, **Serial No.**, **Manufacturer**, **Model**, and (for hired plant) **Vendor No.**, **On-Hire Date** and **Off-Hire Date**.
6. Enter the default **Cost Rate** and **Hire Rate** and the **Rate Unit of Measure** they apply to (for example HOUR or DAY).
7. Optionally set **Meter Unit** (such as HOURS or KM) so meter readings are recorded in a known unit.

### 3. Set project-specific or dated rates (optional)

1. From the Equipment Card or list, open **Rates**.
2. Add a line with a **Starting Date** and the **Unit Cost** and **Hire Rate** that apply from that date.
3. To make a rate apply to one project only, fill the **Project No.**; leave it blank for an all-projects rate.
4. When usage is recorded, the system uses the project-specific rate first (latest starting date on or before the usage date), then the blank-project rate, then the equipment's default Cost Rate.

### 4. Record and post usage to a project

1. Open the **Equipment Usage** worksheet.
2. On a new line, choose the **Equipment No.** The unit of measure and unit cost default automatically from the equipment and its rates.
3. Enter the **Project No.** (only open projects are allowed) and, if used, the **Project Task No.**
4. Enter the **Posting Date** and the **Quantity**. The **Total Cost** is calculated as quantity × unit cost.
5. Adjust the **Unit Cost** if needed; the total recalculates.
6. Choose **Post** to post the line, or **Post Batch** to post every line in the worksheet. Each posted line creates a project (job) resource entry and is then removed from the worksheet.
7. Equipment that is **In Maintenance** cannot be posted; clear maintenance first.

### 5. Record meter readings

1. From the Equipment Card or list, open **Meter Entries**.
2. Add a line with the **Reading Date** and the current **Meter Reading**.
3. The equipment's current meter reading is updated to the latest entry automatically.

### 6. Log maintenance

1. From the Equipment Card or list, open **Maintenance**.
2. Add a line with the **Maintenance Date**, **Maintenance Type** (Service / Repair / Inspection / Other), **Description** and **Cost**, and the **Vendor No.** that did the work.
3. Optionally record the **Meter Reading** at service, and the **Next Service Date** and **Next Service Meter**.
4. On entry, the equipment's **Last Service Date** is stamped from the maintenance date, and the next-service date, next-service meter and meter reading are updated when you supply them.
