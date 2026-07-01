namespace Construction.Core;

using Construction.CostBreakdown;
using Construction.CostControl;
using Construction.Equipment;
using Construction.Estimating;
using Construction.ProgressBilling;
using Construction.Retention;
using Construction.Scheduling;
using Construction.Setup;
using Construction.Subcontracts;
using Microsoft.Projects.Project.Job;

page 50023 "CONS Construction Manager RC"
{
    PageType = RoleCenter;
    Caption = 'Construction Manager';

    layout
    {
        area(RoleCenter)
        {
            part(Activities; "CONS Construction Activities")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Sections)
        {
            group(ProjectsSection)
            {
                Caption = 'Projects';

                action(ProjectList)
                {
                    Caption = 'Projects';
                    ApplicationArea = All;
                    RunObject = page "Job List";
                    Image = Job;
                    ToolTip = 'Opens the list of projects.';
                }
            }
            group(EstimatingSection)
            {
                Caption = 'Estimating';

                action(BillsOfQuantities)
                {
                    Caption = 'Bills of Quantities';
                    ApplicationArea = CONSEstimating;
                    RunObject = page "CONS Bill of Quantities List";
                    Image = Quote;
                    ToolTip = 'Opens the list of bills of quantities (estimates).';
                }
            }
            group(CostControlSection)
            {
                Caption = 'Cost Control';

                action(CostBreakdown)
                {
                    Caption = 'Cost Breakdown';
                    ApplicationArea = CONSCostControl;
                    RunObject = page "CONS Cost Breakdown";
                    Image = ItemCosts;
                    ToolTip = 'Opens the cost breakdown structure.';
                }
                action(ProjectCostControl)
                {
                    Caption = 'Project Cost Control';
                    ApplicationArea = CONSCostControl;
                    RunObject = page "CONS Project Cost Control";
                    Image = Costs;
                    ToolTip = 'Opens committed-cost and cost-to-complete control for projects.';
                }
            }
            group(ProgressBillingSection)
            {
                Caption = 'Progress Billing';

                action(ProgressBillingApplications)
                {
                    Caption = 'Progress Billing Applications';
                    ApplicationArea = CONSProgressBilling;
                    RunObject = page "CONS Progress Billing List";
                    Image = Document;
                    ToolTip = 'Opens the list of progress billing applications.';
                }
                action(RetentionEntries)
                {
                    Caption = 'Retention Entries';
                    ApplicationArea = CONSProgressBilling;
                    RunObject = page "CONS Retention Entries";
                    Image = LedgerEntries;
                    ToolTip = 'Opens the retention sub-ledger.';
                }
            }
            group(SubcontractsSection)
            {
                Caption = 'Subcontracts';

                action(Subcontracts)
                {
                    Caption = 'Subcontracts';
                    ApplicationArea = CONSSubcontracts;
                    RunObject = page "CONS Subcontract List";
                    Image = OrderList;
                    ToolTip = 'Opens the list of subcontracts.';
                }
                action(ChangeOrders)
                {
                    Caption = 'Change Orders';
                    ApplicationArea = CONSSubcontracts;
                    RunObject = page "CONS Change Order List";
                    Image = ChangeStatus;
                    ToolTip = 'Opens the list of change orders / variations.';
                }
                action(SubcontractorClaims)
                {
                    Caption = 'Subcontractor Claims';
                    ApplicationArea = CONSSubcontracts;
                    RunObject = page "CONS Subc Claim List";
                    Image = Payment;
                    ToolTip = 'Opens the list of subcontractor progress claims.';
                }
            }
            group(EquipmentSection)
            {
                Caption = 'Equipment & Plant';

                action(Equipment)
                {
                    Caption = 'Equipment';
                    ApplicationArea = CONSEquipment;
                    RunObject = page "CONS Equipment List";
                    Image = FixedAssets;
                    ToolTip = 'Opens the equipment register.';
                }
            }
            group(SchedulingSection)
            {
                Caption = 'Scheduling & Resource Planning';

                action(ProjectSchedule)
                {
                    Caption = 'Project Schedule';
                    ApplicationArea = CONSScheduling;
                    RunObject = page "CONS Project Schedule";
                    Image = Timesheet;
                    ToolTip = 'Opens the project task schedule.';
                }
                action(ProjectGantt)
                {
                    Caption = 'Project Gantt';
                    ApplicationArea = CONSScheduling;
                    RunObject = page "CONS Project Gantt";
                    Image = Calendar;
                    ToolTip = 'Opens the project Gantt chart.';
                }
                action(TaskDependencies)
                {
                    Caption = 'Task Dependencies';
                    ApplicationArea = CONSScheduling;
                    RunObject = page "CONS Task Dependencies";
                    Image = Relationship;
                    ToolTip = 'Opens the task dependencies.';
                }
                action(ResourceAssignments)
                {
                    Caption = 'Resource Assignments';
                    ApplicationArea = CONSScheduling;
                    RunObject = page "CONS Resource Assignments";
                    Image = Resource;
                    ToolTip = 'Opens the crew and resource assignments.';
                }
            }
        }
        area(Embedding)
        {
            action(EmbeddedProjects)
            {
                Caption = 'Projects';
                ApplicationArea = All;
                RunObject = page "Job List";
                Image = Job;
                ToolTip = 'Opens the list of projects.';
            }
        }
        area(Creation)
        {
            action(NewBillOfQuantities)
            {
                Caption = 'Bill of Quantities';
                ApplicationArea = CONSEstimating;
                RunObject = page "CONS Bill of Quantities";
                RunPageMode = Create;
                Image = NewDocument;
                ToolTip = 'Creates a new bill of quantities.';
            }
            action(NewProgressBilling)
            {
                Caption = 'Progress Billing Application';
                ApplicationArea = CONSProgressBilling;
                RunObject = page "CONS Progress Billing";
                RunPageMode = Create;
                Image = NewDocument;
                ToolTip = 'Creates a new progress billing application.';
            }
            action(NewSubcontract)
            {
                Caption = 'Subcontract';
                ApplicationArea = CONSSubcontracts;
                RunObject = page "CONS Subcontract";
                RunPageMode = Create;
                Image = NewDocument;
                ToolTip = 'Creates a new subcontract.';
            }
            action(NewChangeOrder)
            {
                Caption = 'Change Order';
                ApplicationArea = CONSSubcontracts;
                RunObject = page "CONS Change Order";
                RunPageMode = Create;
                Image = NewDocument;
                ToolTip = 'Creates a new change order.';
            }
            action(NewSubcontractorClaim)
            {
                Caption = 'Subcontractor Claim';
                ApplicationArea = CONSSubcontracts;
                RunObject = page "CONS Subc Claim";
                RunPageMode = Create;
                Image = NewDocument;
                ToolTip = 'Creates a new subcontractor claim.';
            }
            action(NewEquipment)
            {
                Caption = 'Equipment';
                ApplicationArea = CONSEquipment;
                RunObject = page "CONS Equipment Card";
                RunPageMode = Create;
                Image = New;
                ToolTip = 'Creates a new equipment record.';
            }
        }
        area(Processing)
        {
            action(AssistedSetup)
            {
                Caption = 'Set up Construction Management';
                ApplicationArea = All;
                RunObject = page "CONS Setup Hub";
                Image = Setup;
                ToolTip = 'Opens the guided setup for the construction features.';
            }
            action(ConstructionSetup)
            {
                Caption = 'Construction Setup';
                ApplicationArea = All;
                RunObject = page "CONS Construction Setup";
                Image = SetupLines;
                ToolTip = 'Opens the construction master setup.';
            }
            action(CostTypeSetup)
            {
                Caption = 'Cost Types';
                ApplicationArea = All;
                RunObject = page "CONS Cost Type Setup";
                Image = SetupColumns;
                ToolTip = 'Opens the cost type setup.';
            }
        }
    }
}
