# ---
# jupyter:
#   jupytext:
#     formats: ipynb,py:percent
#     text_representation:
#       extension: .py
#       format_name: percent
#       format_version: '1.3'
#       jupytext_version: 1.14.4
#   kernelspec:
#     display_name: base
#     language: python
#     name: python3
# ---

# %%
import pandas as pd
import seaborn as sns
import plotly.graph_objs as go

# %%
df_normal = pd.read_csv("build/pcie_normal.csv")
df_normal["Time_ms"] = df_normal["Time"] / 1000 / 1000
df_normal["Size"] = df_normal["Size"] * 4
df_pinned = pd.read_csv("build/pcie_pinned.csv")
df_pinned["Time_ms"] = df_pinned["Time"] / 1000 / 1000
df_pinned["Size"] = df_pinned["Size"] * 4
df_pinned_wc = pd.read_csv("build/pcie_pinned_write_combined.csv")
df_pinned_wc["Time_ms"] = df_pinned_wc["Time"] / 1000 / 1000
df_pinned_wc["Size"] = df_pinned_wc["Size"] * 4

df_pinned.head()

# %%
# Define the layout of the plot
layout = go.Layout(
    xaxis=dict(type="log", title="Size (Bytes)"),
    yaxis=dict(type="log", title="Time (ms)"),
    title="Transfer Times (duplex), 16x PCIe 4.0",
)

# Define the data for the plot
trace1 = go.Scatter(
    x=df_normal["Size"], y=df_normal["Time_ms"], mode="markers", name="Normal"
)
trace2 = go.Scatter(
    x=df_pinned["Size"], y=df_pinned["Time_ms"], mode="markers", name="Pinned"
)
data = [trace1, trace2]

# Create the plot
fig = go.Figure(data=data, layout=layout)

fig.write_image("pcie.png")

# Display the plot
fig.show()

# %%
