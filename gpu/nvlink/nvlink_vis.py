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
import plotly.graph_objs as go

# %%
df_nvlink = pd.read_csv("build/cudaMemcpyPeerAsync.csv")
df_nvlink["Time_ms"] = df_nvlink["Time"] / 1000 / 1000
df_nvlink["Size"] = df_nvlink["Size"] * 4

df_nvlink.head()

# %%
# Define the layout of the plot
layout = go.Layout(
    xaxis=dict(type="log", title="Size (Bytes)"),
    yaxis=dict(type="log", title="Time (ms)"),
    title="Transfer Times (duplex)",
)

# Define the data for the plot
trace1 = go.Scatter(
    x=df_nvlink["Size"], y=df_nvlink["Time_ms"], mode="markers", name="Normal"
)
data = [trace1]

# Create the plot
fig = go.Figure(data=data, layout=layout)

fig.write_image("nvlink.png")

# Display the plot
fig.show()
