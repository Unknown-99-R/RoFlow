param()

# ─── AES ENCRYPTION FUNCTIONS ──────────────────────────────────────

function Get-AESKey {
    # Exactly 32 characters = 32 bytes = AES-256
    $key = "ThisIsARobiKeyUnknow9900@!!9900"  # ← customize this, total 32 chars
    return [System.Text.Encoding]::UTF8.GetBytes($key)
}



function Encrypt-WithAES {
    param (
        [Parameter(Mandatory)] [string] $PlainText
    )

    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = Get-AESKey
    $aes.GenerateIV()

    $encryptor = $aes.CreateEncryptor()
    $plainBytes = [System.Text.Encoding]::UTF8.GetBytes($PlainText)
    $cipherBytes = $encryptor.TransformFinalBlock($plainBytes, 0, $plainBytes.Length)

    # Store IV + ciphertext together
    $output = $aes.IV + $cipherBytes
    [System.Convert]::ToBase64String($output)
}

function Decrypt-WithAES {
    param (
        [Parameter(Mandatory)] [string] $EncryptedBase64
    )

    $combined = [System.Convert]::FromBase64String($EncryptedBase64)

    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = Get-AESKey

    $iv = $combined[0..15]
    $cipherBytes = $combined[16..($combined.Length - 1)]

    $aes.IV = $iv
    $decryptor = $aes.CreateDecryptor()
    $plainBytes = $decryptor.TransformFinalBlock($cipherBytes, 0, $cipherBytes.Length)

    [System.Text.Encoding]::UTF8.GetString($plainBytes)
}


# ───────────────────────────────────────────────────────────────────
# EMBEDDED MAIN WINDOW XAML
# ───────────────────────────────────────────────────────────────────

$MainWindowXaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="RoFlow" Height="700" Width="900"
        Background="{DynamicResource WindowBackgroundBrush}" FontFamily="Segoe UI" FontSize="13">
    <Window.Resources>
        <!-- DataTemplate for project tile -->
        <DataTemplate x:Key="ProjectTileTemplate">
            <Border x:Name="TileBorder"
                    Background="{DynamicResource SurfaceOfTile}"
                    CornerRadius="8"
                    Padding="6"
                    Margin="6"
                    BorderThickness="2"
                    Effect="{DynamicResource TileShadow}">
                <StackPanel HorizontalAlignment="Center"
                            VerticalAlignment="Center">
                    <TextBlock Text="{Binding Number}"
                               FontSize="10"
                               Foreground="{DynamicResource GrayNumberBrush}"
                               HorizontalAlignment="Center"
                               Margin="0,0,0,1"/>
                    <TextBlock Text="{Binding Name}"
                               TextWrapping="NoWrap"
                               TextTrimming="CharacterEllipsis"
                               HorizontalAlignment="Center"
                               VerticalAlignment="Center"
                               FontSize="12"
                               FontWeight="SemiBold"
                               Foreground="{DynamicResource PrimaryForegroundBrush}"
                               Margin="0,0,0,1"/>
                    <TextBlock Text="{Binding Priority}"
                               FontSize="10"
                               HorizontalAlignment="Center"
                               Margin="0,0,0,3">
                        <TextBlock.Style>
                            <Style TargetType="TextBlock">
                                <Setter Property="Foreground" Value="{DynamicResource GrayNumberBrush}"/>
                                <Style.Triggers>
                                    <DataTrigger Binding="{Binding Priority}" Value="Low">
                                        <Setter Property="Foreground" Value="Green"/>
                                    </DataTrigger>
                                    <DataTrigger Binding="{Binding Priority}" Value="Medium">
                                        <Setter Property="Foreground" Value="Goldenrod"/>
                                    </DataTrigger>
                                    <DataTrigger Binding="{Binding Priority}" Value="High">
                                        <Setter Property="Foreground" Value="Red"/>
                                    </DataTrigger>
                                </Style.Triggers>
                            </Style>
                        </TextBlock.Style>
                    </TextBlock>
                    <TextBlock HorizontalAlignment="Center"
           FontSize="10"
           Foreground="{DynamicResource GrayNumberBrush}"
           Margin="0,1,0,0">
  <TextBlock.Text>
    <PriorityBinding StringFormat="{}{0:MMM dd, yyyy}">
      <Binding Path="CreationDate.value"/>
      <Binding Path="CreationDate"/>
    </PriorityBinding>
  </TextBlock.Text>
</TextBlock>

                </StackPanel>
            </Border>
            <DataTemplate.Triggers>
                <DataTrigger Binding="{Binding Status}" Value="Complete">
                    <Setter TargetName="TileBorder" Property="BorderBrush" Value="{DynamicResource CompleteTile}"/>
                </DataTrigger>
                <DataTrigger Binding="{Binding Status}" Value="Ongoing">
                    <Setter TargetName="TileBorder" Property="BorderBrush" Value="{DynamicResource OngoingTile}"/>
                </DataTrigger>
                <DataTrigger Binding="{Binding Status}" Value="Not Started">
                    <Setter TargetName="TileBorder" Property="BorderBrush" Value="{DynamicResource NotStartedTile}"/>
                </DataTrigger>
            </DataTemplate.Triggers>
        </DataTemplate>

        <!-- DropShadow for tiles -->
        <DropShadowEffect x:Key="TileShadow"
                          BlurRadius="8"
                          ShadowDepth="0"
                          Opacity="0.2"/>

        <!-- Flat menu style: no background or border -->
        <Style x:Key="FlatMenuStyle" TargetType="Menu">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="BorderBrush" Value="Transparent"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Menu">
                        <StackPanel Orientation="Horizontal" IsItemsHost="True"/>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Grid Margin="10">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>   <!-- Menu -->
            <RowDefinition Height="Auto"/>   <!-- Top bar -->
            <RowDefinition Height="*"/>      <!-- Project list -->
        </Grid.RowDefinitions>

        <!-- Menu -->
        <Menu Grid.Row="0"
              Style="{StaticResource FlatMenuStyle}"
              Foreground="{DynamicResource GrayNumberBrush}">
            <MenuItem Header="Settings"
                      Style="{DynamicResource TopMenuItemStyle}"
                      ItemContainerStyle="{DynamicResource SubMenuItemStyle}">
                <MenuItem x:Name="ChangeDataFileMenuItem"
          Header="Change Data File"
          Foreground="{DynamicResource SpecialMenuItemForegroundBrush}"/>
<MenuItem x:Name="DarkModeMenuItem"
          Header="Dark Mode"
          IsCheckable="True"
          Foreground="{DynamicResource SpecialMenuItemForegroundBrush}"/>
<MenuItem x:Name="ViewLogsMenuItem"
          Header="View Logs"
          Foreground="{DynamicResource SpecialMenuItemForegroundBrush}"/>

            </MenuItem>
            <MenuItem x:Name="StatusFilterMenuItem" Header="Status: All"
          Style="{DynamicResource TopMenuItemStyle}"
          ItemContainerStyle="{DynamicResource SubMenuItemStyle}">
  <MenuItem x:Name="FilterAllMenuItem"        Header="All"
            Foreground="{DynamicResource SpecialMenuItemForegroundBrush}"/>
  <MenuItem x:Name="FilterNotStartedMenuItem" Header="Not Started"
            Foreground="{DynamicResource SpecialMenuItemForegroundBrush}"/>
  <MenuItem x:Name="FilterOngoingMenuItem"    Header="Ongoing"
            Foreground="{DynamicResource SpecialMenuItemForegroundBrush}"/>
  <MenuItem x:Name="FilterCompleteMenuItem"   Header="Complete"
            Foreground="{DynamicResource SpecialMenuItemForegroundBrush}"/>
</MenuItem>

        </Menu>

        <!-- Top bar -->
        <Grid Grid.Row="1">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>

            <!-- Search with watermark -->
            <TextBox x:Name="SearchBox"
                     Grid.Column="0"
                     Height="30"
                     Margin="0,0,8,0"
                     VerticalAlignment="Center"
                     Padding="5"
                     Background="{DynamicResource ContentBackgroundBrush}">
                <TextBox.Style>
                    <Style TargetType="TextBox">
                        <Setter Property="Template">
                            <Setter.Value>
                                <ControlTemplate TargetType="TextBox">
                                    <Border Background="{TemplateBinding Background}"
                                            BorderBrush="{TemplateBinding BorderBrush}"
                                            BorderThickness="{TemplateBinding BorderThickness}"
                                            CornerRadius="2">
                                        <Grid>
                                            <ScrollViewer x:Name="PART_ContentHost"
                                                          Background="Transparent"/>
                                            <TextBlock x:Name="Watermark"
                                                       Text="Search"
                                                       Foreground="{DynamicResource PlaceholderBrush}"
                                                       Margin="7,0,0,0"
                                                       VerticalAlignment="Center"
                                                       IsHitTestVisible="False"
                                                       Visibility="Collapsed"/>
                                        </Grid>
                                    </Border>
                                    <ControlTemplate.Triggers>
                                        <Trigger Property="Text" Value="">
                                            <Setter TargetName="Watermark"
                                                    Property="Visibility"
                                                    Value="Visible"/>
                                        </Trigger>
                                        <Trigger Property="IsKeyboardFocused" Value="True">
                                            <Setter TargetName="Watermark"
                                                    Property="Visibility"
                                                    Value="Collapsed"/>
                                        </Trigger>
                                    </ControlTemplate.Triggers>
                                </ControlTemplate>
                            </Setter.Value>
                        </Setter>
                    </Style>
                </TextBox.Style>
            </TextBox>

            <!-- Date range filter -->
            <ComboBox x:Name="DateRangeFilter"
                      Grid.Column="1"
                      Height="30"
                      Margin="0,0,8,0"
                      VerticalAlignment="Center"
                      SelectedIndex="0">
                <ComboBoxItem>All</ComboBoxItem>
                <ComboBoxItem>Last 30 Days</ComboBoxItem>
                <ComboBoxItem>Last 6 Months</ComboBoxItem>
                <ComboBoxItem>Last Year</ComboBoxItem>
            </ComboBox>

            <!-- Refresh -->
            <Button x:Name="RefreshButton"
                    Grid.Column="2"
                    Content="Refresh"
                    Height="30"
                    Margin="0,0,8,0"
                    Padding="10,5"/>

            <!-- New ticket -->
            <Button x:Name="AddProjectButton"
                    Grid.Column="3"
                    Content="New Ticket"
                    Height="30"
                    Padding="10,5"/>
        </Grid>

        <!-- Project tiles -->
        <ListBox x:Name="ProjectList"
                 Grid.Row="2"
                 ItemTemplate="{StaticResource ProjectTileTemplate}"
                 HorizontalContentAlignment="Stretch"
                 VerticalContentAlignment="Top"
                 BorderThickness="0"
                 Background="Transparent"
                 ScrollViewer.HorizontalScrollBarVisibility="Disabled">
            <ListBox.ItemsPanel>
                <ItemsPanelTemplate>
                    <WrapPanel/>
                </ItemsPanelTemplate>
            </ListBox.ItemsPanel>
            <ListBox.Resources>
                <SolidColorBrush x:Key="{x:Static SystemColors.HighlightBrushKey}"     Color="#FF0078D7"/>
                <SolidColorBrush x:Key="{x:Static SystemColors.HighlightTextBrushKey}" Color="White"/>
            </ListBox.Resources>
             <ListBox.GroupStyle>
  <GroupStyle>
    <GroupStyle.HeaderTemplate>
      <DataTemplate>
        <TextBlock Text="{Binding Name}"
                   FontSize="12"
                   FontWeight="Bold"
                   Foreground="{DynamicResource PrimaryForegroundBrush}"
                   Margin="0,6,0,3"/>
      </DataTemplate>
    </GroupStyle.HeaderTemplate>
    </GroupStyle>
  </ListBox.GroupStyle>
</ListBox>
        <!-- Information icon in the lower-right corner -->
        <Canvas Grid.Row="2"
                Width="20" Height="20"
                HorizontalAlignment="Right"
                VerticalAlignment="Bottom"
                Margin="0,0,8,8"
                Panel.ZIndex="1">
             <Ellipse Width="20" Height="20"
                     Stroke="{DynamicResource BorderBrushColor}"
                     StrokeThickness="2"
                     Fill="Transparent"/>
            <Ellipse Width="2" Height="2"
                     Fill="{DynamicResource PrimaryForegroundBrush}"
                     Canvas.Left="9" Canvas.Top="4"/>
            <Rectangle Width="2" Height="8"
                       Fill="{DynamicResource PrimaryForegroundBrush}"
                       Canvas.Left="9" Canvas.Top="8"/>
            <Canvas.ToolTip>
                <ToolTip Background="{DynamicResource PopupBackgroundBrush}"
                         Foreground="{DynamicResource PopupForegroundBrush}">
                    <Border Padding="8" Background="{DynamicResource PopupBackgroundBrush}" CornerRadius="4">
                        <StackPanel MaxWidth="300">
                            <!-- Step 1 -->
                            <TextBlock Text="Step 1: Open the New Ticket Dialog"
                                       FontWeight="Bold"
                                       Margin="0,0,0,4"/>
                            <TextBlock Text="In the main windows top toolbar, click New Ticket."
                                       TextWrapping="Wrap"
                                       Margin="0,0,0,0"/>
                            <TextBlock Text="A modal Project Detail window will pop up."
                                       TextWrapping="Wrap"
                                       Margin="0,0,0,8"/>

                            <!-- Step 2 -->
                            <TextBlock Text="Step 2: Fill in the Basic Ticket Info"
                                       FontWeight="Bold"
                                       Margin="0,0,0,4"/>
                            <TextBlock Text="Number auto-generated for you (no need to edit)."
                                       TextWrapping="Wrap"
                                       Margin="0,0,0,0"/>
                            <TextBlock Text="Name enter a short, descriptive title for the ticket."
                                       TextWrapping="Wrap"
                                       Margin="0,0,0,0"/>
                            <TextBlock Text="Status choose Not Started, Ongoing, or Complete."
                                       TextWrapping="Wrap"
                                       Margin="0,0,0,0"/>
                            <TextBlock Text="Subject (optional) a one-line summary field."
                                       TextWrapping="Wrap"
                                       Margin="0,0,0,8"/>

                            <!-- Step 3 -->
                            <TextBlock Text="Step 3: (Optional) Add Work Log Entries"
                                       FontWeight="Bold"
                                       Margin="0,0,0,4"/>
                            <TextBlock Text="In the bottom half of the dialog, under Log Entries, type a description of what you did."
                                       TextWrapping="Wrap"
                                       Margin="0,0,0,0"/>
                            <TextBlock Text="Enter a duration of time it took."
                                       TextWrapping="Wrap"
                                       Margin="0,0,0,0"/>
                            <TextBlock Text="Click Add Entry."
                                       TextWrapping="Wrap"
                                       Margin="0,0,0,0"/>
                            <TextBlock Text="Repeat for each additional log entry."
                                       TextWrapping="Wrap"
                                       Margin="0,0,0,8"/>

                            <!-- Step 4 -->
                            <TextBlock Text="Step 4: Save Your New Ticket"
                                       FontWeight="Bold"
                                       Margin="0,0,0,4"/>
                            <TextBlock Text="Click Save."
                                       TextWrapping="Wrap"
                                       Margin="0,0,0,0"/>
                            <TextBlock Text="The dialog closes and your new ticket appears immediately in the main grid."
                                       TextWrapping="Wrap"
                                       Margin="0,0,0,8"/>

                            <!-- Step 5 -->
                            <TextBlock Text="Step 5: Verify and Refresh"
                                       FontWeight="Bold"
                                       Margin="0,0,0,4"/>
                            <TextBlock Text="The list auto-refreshes every few seconds."
                                       TextWrapping="Wrap"
                                       Margin="0,0,0,0"/>
                            <TextBlock Text="Or click Refresh in the toolbar to see it right away."
                                       TextWrapping="Wrap"
                                       Margin="0,0,0,8"/>

                            <!-- Step 6 -->
                            <TextBlock Text="Step 6: Find or Filter"
                                       FontWeight="Bold"
                                       Margin="0,0,0,4"/>
                            <TextBlock Text="Use the Search box to jump to tickets by name or number."
                                       TextWrapping="Wrap"
                                       Margin="0,0,0,0"/>
                            <TextBlock Text="Use the Date Range drop-down to narrow the list"
                                       TextWrapping="Wrap"
                                       Margin="0,0,0,8"/>

                            <!-- Credit line -->
                            <TextBlock Text="Created by SrA Robichaud, Cannon"
                                       FontStyle="Italic"
                                       TextAlignment="Right"
                                       Margin="0,8,0,0"/>
                        </StackPanel>
                    </Border>
                </ToolTip>
            </Canvas.ToolTip>
        </Canvas>
    </Grid>
</Window>
'@
# ───────────────────────────────────────────────────────────────────
# EMBEDDED ProjectDetailWindow XAML
# ───────────────────────────────────────────────────────────────────
$ProjectDetailWindowXaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Ticket Details" Height="700" Width="900"
        Background="{DynamicResource WindowBackgroundBrush}" FontFamily="Segoe UI" FontSize="13"
        WindowStartupLocation="CenterOwner">
  <Grid Margin="10">
    <!-- 1) Top‑level row definitions -->
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>   <!-- Project info -->
      <RowDefinition Height="Auto"/>   <!-- Attachments -->
      <RowDefinition Height="Auto"/>   <!-- New entry inputs -->
      <RowDefinition Height="*"/>      <!-- Work log list -->
      <RowDefinition Height="Auto"/>   <!-- Remove update button -->
      <RowDefinition Height="Auto"/>   <!-- Buttons: Delete, Save, Cancel -->
    </Grid.RowDefinitions>

    <!-- 2) Project Information Section -->
    <Grid Grid.Row="0" Margin="0,0,0,10">
      <!-- 2a) Nested row+column definitions go first -->
      <Grid.RowDefinitions>
        <RowDefinition Height="Auto"/> <!-- Ticket number -->
        <RowDefinition Height="Auto"/> <!-- Name -->
        <RowDefinition Height="Auto"/> <!-- Status -->
        <RowDefinition Height="Auto"/> <!-- Subject -->
        <RowDefinition Height="Auto"/> <!-- Priority -->
        <RowDefinition Height="Auto"/>
      </Grid.RowDefinitions>
      <Grid.ColumnDefinitions>
        <ColumnDefinition Width="Auto"/>
        <ColumnDefinition Width="*"/>
      </Grid.ColumnDefinitions>

      <!-- 2b) Now the controls -->
      <TextBlock Text="Ticket #:" Grid.Row="0" Grid.Column="0" Margin="0,0,5,5" VerticalAlignment="Center"/>
      <TextBlock x:Name="NumberTextBlock" Grid.Row="0" Grid.Column="1" Margin="0,0,0,5" Padding="4"/>

      <!-- Name -->
      <TextBlock Text="Name:" Grid.Row="1" Grid.Column="0" Margin="0,0,5,5" VerticalAlignment="Center"/>
      <TextBox x:Name="NameTextBox"
               Grid.Row="1" Grid.Column="1"
               Style="{StaticResource RoundedTextBox}"
               Margin="0,0,0,5"
               Padding="4"/>

      <!-- Status -->
<TextBlock Text="Status:" Grid.Row="2" Grid.Column="0" Margin="0,0,5,5" VerticalAlignment="Center"/>
<ComboBox x:Name="StatusComboBox"
          Grid.Row="2" Grid.Column="1"
          Margin="0,0,0,5"/>



      <!-- Subject -->
      <TextBlock Text="Subject:" Grid.Row="3" Grid.Column="0" Margin="0,0,5,5" VerticalAlignment="Center"/>
      <TextBox x:Name="SubjectTextBox"
               Grid.Row="3" Grid.Column="1"
               Style="{StaticResource RoundedTextBox}"
               Margin="0,0,0,5"
               Padding="4"
               ToolTip="Separate tags with commas"/>

      <!-- Priority -->
<TextBlock Text="Priority:" Grid.Row="4" Grid.Column="0" Margin="0,0,5,5" VerticalAlignment="Center"/>
<ComboBox x:Name="PriorityComboBox"
          Grid.Row="4" Grid.Column="1"
          Margin="0,0,0,5">
  <ComboBoxItem>Low</ComboBoxItem>
  <ComboBoxItem>Medium</ComboBoxItem>
  <ComboBoxItem>High</ComboBoxItem>
</ComboBox>


    </Grid>

    <!-- 3) Attachments Section -->
    <Grid Grid.Row="1" Margin="0,0,0,10">
      <Grid.RowDefinitions>
        <RowDefinition Height="Auto"/>
        <RowDefinition Height="*"/>
      </Grid.RowDefinitions>
      <StackPanel Orientation="Horizontal" Grid.Row="0">
        <TextBlock Text="Attachments:" FontWeight="Bold" VerticalAlignment="Center"/>
        <Button x:Name="AddAttachmentButton" Content="Add..." Margin="10,0,0,0" Padding="6,3"/>
        <Button x:Name="RemoveAttachmentButton" Content="Remove" Margin="5,0,0,0" Padding="6,3"/>
      </StackPanel>
      <ListBox x:Name="AttachmentListBox" Grid.Row="1" Margin="0,5,0,0"/>
    </Grid>
    <!-- 4) New Work Log Entry Section -->
    <Grid Grid.Row="2" Margin="0,0,0,10">
      <Grid.ColumnDefinitions>
        <ColumnDefinition Width="Auto"/>
        <ColumnDefinition Width="*"/>
        <ColumnDefinition Width="Auto"/>
        <ColumnDefinition Width="80"/>
        <ColumnDefinition Width="Auto"/>
      </Grid.ColumnDefinitions>
      <TextBlock Text="Description:" Grid.Column="0" VerticalAlignment="Center" Margin="0,0,5,0"/>
      <TextBox x:Name="DescriptionTextBox" Grid.Column="1" Margin="0,0,10,0" Padding="4" Style="{StaticResource RoundedTextBox}"/>
      <TextBlock Text="Rank / Name:" Grid.Column="2" VerticalAlignment="Center" Margin="0,0,5,0"/>
      <TextBox x:Name="DurationTextBox" Grid.Column="3" Padding="4" Style="{StaticResource RoundedTextBox}"/>
      <Button x:Name="AddEntryButton" Grid.Column="4" Content="Add" Margin="10,0,0,0" Padding="8,4"/>
    </Grid>

    <!-- 5) Work Log List -->
<Border Grid.Row="3"
        CornerRadius="4"
        BorderBrush="{DynamicResource BorderBrushColor}"
        BorderThickness="1"
        Padding="2"
        Margin="0,0,0,10"
        Background="{DynamicResource ContentBackgroundBrush}">
  <ListView x:Name="LogListView"
            Margin="0"
            Background="{DynamicResource ContentBackgroundBrush}"
            Foreground="{DynamicResource PrimaryForegroundBrush}">
    <ListView.Resources>
      <!-- rows -->
      <Style TargetType="ListViewItem">
        <Setter Property="Background" Value="{DynamicResource ContentBackgroundBrush}"/>
        <Setter Property="Foreground" Value="{DynamicResource PrimaryForegroundBrush}"/>
      </Style>
      <!-- column headers -->
      <Style TargetType="GridViewColumnHeader">
        <Setter Property="Background" Value="{DynamicResource ContentBackgroundBrush}"/>
        <Setter Property="Foreground" Value="{DynamicResource PrimaryForegroundBrush}"/>
        <Setter Property="BorderBrush" Value="{DynamicResource BorderBrushColor}"/>
        <Setter Property="BorderThickness" Value="0,0,0,1"/>
      </Style>
    </ListView.Resources>

    <ListView.View>
      <GridView>
        <GridViewColumn Header="Date/Time" Width="150"
                        DisplayMemberBinding="{Binding Timestamp, StringFormat={}{0:g}}"/>
        <GridViewColumn Header="Subject" Width="350"
                        DisplayMemberBinding="{Binding Subject}"/>
        <GridViewColumn Header="Rank / Name" Width="100"
                        DisplayMemberBinding="{Binding Duration}"/>
      </GridView>
    </ListView.View>
  </ListView>
</Border>


    <!-- 6) Remove Update Button -->
    <Button Grid.Row="4" x:Name="RemoveEntryButton" Content="Remove" Margin="0,0,0,10" Padding="10,5" HorizontalAlignment="Right"/>

    <!-- 7) Buttons Section -->
    <StackPanel Grid.Row="5" Orientation="Horizontal" HorizontalAlignment="Stretch">
      <Button x:Name="DeleteProjectButton" Content="Delete Ticket" Margin="0,0,10,0" Padding="10,5" HorizontalAlignment="Left"/>
      <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
        <Button x:Name="SaveButton"   Content="Save"   Margin="5,0,0,0" Padding="10,5"/>
        <Button x:Name="CancelButton" Content="Cancel" Margin="5,0,0,0" Padding="10,5" IsCancel="True"/>
        <Button x:Name="TransferTicketButton" Content="Transfer Ticket" Margin="5,0,0,0" Padding="10,5"/>
      </StackPanel>
    </StackPanel>
  </Grid>
</Window>
'@
# 1. Load Required Assemblies & Hide Console

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase
$signature = @'
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
'@
# ───────────────────────────────────────────────────────────────────
# EMBEDDED Styles XAML
# ───────────────────────────────────────────────────────────────────
$StylesXaml    = @'
<ResourceDictionary xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
                    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">
    <SolidColorBrush x:Key="WindowBackgroundBrush" Color="Lavender"/>
    <SolidColorBrush x:Key="ContentBackgroundBrush" Color="White"/>
    <SolidColorBrush x:Key="BorderBrushColor" Color="#FFCCCCCC"/>
    <SolidColorBrush x:Key="PrimaryForegroundBrush" Color="Black"/>
    <SolidColorBrush x:Key="GrayNumberBrush" Color="Gray"/>
    <SolidColorBrush x:Key="SurfaceOfTile" Color= "White"/>
    <SolidColorBrush x:Key="NotStartedTile" Color= "#9B3333"/>
    <SolidColorBrush x:Key="OngoingTile" Color= "Gold"/>
    <SolidColorBrush x:Key="CompleteTile" Color= "#669B66"/>
    <SolidColorBrush x:Key="PopupBackgroundBrush" Color="White"/>
    <SolidColorBrush x:Key="PopupForegroundBrush" Color="Black"/>
    <SolidColorBrush x:Key="PlaceholderBrush" Color="LightGray"/>
    <SolidColorBrush x:Key="SelectionBackgroundBrush" Color="#FF0078D7"/>
    <SolidColorBrush x:Key="SelectionForegroundBrush" Color="White"/>
    <SolidColorBrush x:Key="SpecialMenuItemForegroundBrush" Color="Black"/>


<!-- Make ComboBoxes match light theme inputs -->
<Style TargetType="ComboBox">
  <Setter Property="Background"      Value="{DynamicResource ContentBackgroundBrush}"/>
  <Setter Property="Foreground"      Value="{DynamicResource PrimaryForegroundBrush}"/>
  <Setter Property="BorderBrush"     Value="{DynamicResource BorderBrushColor}"/>
  <Setter Property="BorderThickness" Value="1"/>
  <Setter Property="Padding"         Value="4"/>
</Style>

<!-- Dropdown items selection colors -->
<Style TargetType="ComboBoxItem">
  <Setter Property="Foreground" Value="{DynamicResource PrimaryForegroundBrush}"/>
  <Style.Triggers>
    <Trigger Property="IsSelected" Value="True">
      <Setter Property="Background" Value="{DynamicResource SelectionBackgroundBrush}"/>
      <Setter Property="Foreground" Value="{DynamicResource SelectionForegroundBrush}"/>
    </Trigger>
  </Style.Triggers>
</Style>

<!-- Menu item styles -->
<Style x:Key="TopMenuItemStyle" TargetType="MenuItem">
  <Setter Property="Foreground" Value="{DynamicResource PrimaryForegroundBrush}"/>
  <Style.Triggers>
    <Trigger Property="IsHighlighted" Value="True">
      <Setter Property="Background" Value="{DynamicResource SelectionBackgroundBrush}"/>
      <Setter Property="Foreground" Value="{DynamicResource SelectionForegroundBrush}"/>
    </Trigger>
  </Style.Triggers>
</Style>

<Style x:Key="SubMenuItemStyle" TargetType="MenuItem">
  <Setter Property="Foreground" Value="{DynamicResource PrimaryForegroundBrush}"/>
  <Style.Triggers>
    <Trigger Property="IsHighlighted" Value="True">
      <Setter Property="Background" Value="{DynamicResource SelectionBackgroundBrush}"/>
      <Setter Property="Foreground" Value="{DynamicResource SelectionForegroundBrush}"/>
    </Trigger>
  </Style.Triggers>
</Style>

<!-- Ensure the popup list (dropdown) is NOT white in light theme -->
<SolidColorBrush x:Key="{x:Static SystemColors.WindowBrushKey}"     Color="#FFFFFFFF"/>
<SolidColorBrush x:Key="{x:Static SystemColors.WindowTextBrushKey}" Color="#FF000000"/>

    <!-- Default text color -->
    <Style TargetType="TextBlock">
        <Setter Property="Foreground" Value="{DynamicResource PrimaryForegroundBrush}"/>
    </Style>
    <!-- Flat button style for a Windows 11 look -->
     <Style TargetType="Button">
        <Setter Property="Background" Value="{DynamicResource ContentBackgroundBrush}"/>
        <Setter Property="BorderBrush" Value="{DynamicResource BorderBrushColor}"/>
        <Setter Property="BorderThickness" Value="1"/>
        <Setter Property="Foreground" Value="{DynamicResource PrimaryForegroundBrush}"/>
        <Setter Property="Padding" Value="8,4"/>
        <Setter Property="Cursor" Value="Hand"/>
        <Setter Property="Template">
            <Setter.Value>
                <ControlTemplate TargetType="Button">
                    <Border x:Name="border" Background="{TemplateBinding Background}" 
                            BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}"
                            CornerRadius="4">
                        <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"
                                          Margin="{TemplateBinding Padding}"
                                          Content="{TemplateBinding Content}"/>
                    </Border>
                    <ControlTemplate.Triggers>
                        <Trigger Property="IsMouseOver" Value="True">
                            <Setter TargetName="border" Property="Background" Value="#FFF0F0F0"/>
                        </Trigger>
                        <Trigger Property="IsPressed" Value="True">
                            <Setter TargetName="border" Property="Background" Value="#FFE0E0E0"/>
                        </Trigger>
                        <Trigger Property="IsEnabled" Value="False">
                            <Setter TargetName="border" Property="Opacity" Value="0.6"/>
                        </Trigger>
                    </ControlTemplate.Triggers>
                </ControlTemplate>
            </Setter.Value>
        </Setter>
    </Style>

    <!-- Style for the info icon container -->
    <Style x:Key="InfoIconStyle" TargetType="Grid">
        <Setter Property="Width" Value="24"/>
        <Setter Property="Height" Value="24"/>
        <Setter Property="Margin" Value="0,0,10,10"/>
    </Style>

    <!-- Style for circular info icon -->
    <Style x:Key="InfoIconEllipseStyle" TargetType="Ellipse">
        <Setter Property="Width" Value="24"/>
        <Setter Property="Height" Value="24"/>
        <Setter Property="Fill" Value="#0078D7"/>
        <Setter Property="StrokeThickness" Value="0"/>
        <Style.Triggers>
            <Trigger Property="IsMouseOver" Value="True">
                <Setter Property="Fill" Value="#005A9E"/>
            </Trigger>
        </Style.Triggers>
    </Style>

    <Style x:Key="InfoIconTextStyle" TargetType="TextBlock">
        <Setter Property="Foreground" Value="{DynamicResource PrimaryForegroundBrush}"/>
        <Setter Property="FontWeight" Value="Bold"/>
        <Setter Property="FontSize" Value="14"/>
        <Setter Property="HorizontalAlignment" Value="Center"/>
        <Setter Property="VerticalAlignment" Value="Center"/>
        <Setter Property="IsHitTestVisible" Value="False"/>
    </Style>

    <!-- Style for priority ComboBox items -->
    <Style x:Key="PriorityItemStyle" TargetType="ComboBoxItem">
        <Style.Triggers>
            <Trigger Property="Content" Value="Low">
                <Setter Property="Foreground" Value="Green"/>
            </Trigger>
            <Trigger Property="Content" Value="Medium">
                <Setter Property="Foreground" Value="Goldenrod"/>
            </Trigger>
            <Trigger Property="Content" Value="High">
                <Setter Property="Foreground" Value="Red"/>
            </Trigger>
        </Style.Triggers>
    </Style>

    <!-- Rounded text box style -->
    <Style x:Key="RoundedTextBox" TargetType="TextBox">
       <Setter Property="Background" Value="{DynamicResource ContentBackgroundBrush}"/>
        <Setter Property="BorderBrush" Value="{DynamicResource BorderBrushColor}"/>
        <Setter Property="Foreground" Value="{DynamicResource PrimaryForegroundBrush}"/>
        <Setter Property="BorderThickness" Value="1"/>
        <Setter Property="Padding" Value="4"/>
        <Setter Property="Template">
            <Setter.Value>
                <ControlTemplate TargetType="TextBox">
                    <Border Background="{TemplateBinding Background}"
                            BorderBrush="{TemplateBinding BorderBrush}"
                            BorderThickness="{TemplateBinding BorderThickness}"
                            CornerRadius="4">
                        <ScrollViewer x:Name="PART_ContentHost"/>
                    </Border>
                </ControlTemplate>
            </Setter.Value>
        </Setter>
    </Style>
</ResourceDictionary>
'@
# ───────────────────────────────────────────────────────────────────
# EMBEDDED DarkStyles XAML
# ───────────────────────────────────────────────────────────────────
$DarkStylesXaml = @'
<!-- DarkStyles.xaml -->
<ResourceDictionary xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
                    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">
    <!-- Base brushes for dark theme -->
     <SolidColorBrush x:Key="WindowBackgroundBrush" Color="#2B2B2B"/>
    <SolidColorBrush x:Key="ContentBackgroundBrush" Color="#4A4A4A"/>
    <SolidColorBrush x:Key="BorderBrushColor" Color="#3C3C50"/>
    <SolidColorBrush x:Key="PrimaryForegroundBrush" Color="White"/>
    <SolidColorBrush x:Key="GrayNumberBrush" Color="#F1F1F1"/>
    <SolidColorBrush x:Key="SurfaceOfTile" Color= "#4B4B4B"/>
    <SolidColorBrush x:Key="NotStartedTile" Color= "#FF1A1A"/>
    <SolidColorBrush x:Key="OngoingTile" Color= "#FEE75C"/>
    <SolidColorBrush x:Key="CompleteTile" Color= "#57F287"/>
    <SolidColorBrush x:Key="PopupBackgroundBrush" Color="#3C3C3C"/>
    <SolidColorBrush x:Key="PopupForegroundBrush" Color="Black"/>
    <SolidColorBrush x:Key="PlaceholderBrush" Color="#888888"/>
    <SolidColorBrush x:Key="SelectionBackgroundBrush" Color="#FF005A9E"/>
    <SolidColorBrush x:Key="SelectionForegroundBrush" Color="White"/>
    <SolidColorBrush x:Key="SpecialMenuItemForegroundBrush" Color="Black"/>


<!-- Make ComboBoxes match dark theme inputs -->
<Style TargetType="ComboBox">
  <Setter Property="Background"      Value="{DynamicResource ContentBackgroundBrush}"/>
  <Setter Property="Foreground"      Value="{DynamicResource PopupForegroundBrush}"/>
  <Setter Property="BorderBrush"     Value="{DynamicResource BorderBrushColor}"/>
  <Setter Property="BorderThickness" Value="1"/>
  <Setter Property="Padding"         Value="4"/>
</Style>


<!-- Dropdown items selection colors -->
<Style TargetType="ComboBoxItem">
   <Setter Property="Foreground" Value="{DynamicResource PrimaryForegroundBrush}"/>
  <Style.Triggers>
    <Trigger Property="IsSelected" Value="True">
      <Setter Property="Background" Value="{DynamicResource SelectionBackgroundBrush}"/>
      <Setter Property="Foreground" Value="{DynamicResource SelectionForegroundBrush}"/>
    </Trigger>
  </Style.Triggers>
</Style>


<!-- Menu item styles -->
<Style x:Key="TopMenuItemStyle" TargetType="MenuItem">
  <Setter Property="Foreground" Value="{DynamicResource PrimaryForegroundBrush}"/>
  <Style.Triggers>
    <Trigger Property="IsHighlighted" Value="True">
      <Setter Property="Background" Value="{DynamicResource SelectionBackgroundBrush}"/>
      <Setter Property="Foreground" Value="{DynamicResource SelectionForegroundBrush}"/>
    </Trigger>
  </Style.Triggers>
</Style>

<Style x:Key="SubMenuItemStyle" TargetType="MenuItem">
  <Setter Property="Foreground" Value="{DynamicResource PrimaryForegroundBrush}"/>
  <Style.Triggers>
    <Trigger Property="IsHighlighted" Value="True">
      <Setter Property="Background" Value="{DynamicResource SelectionBackgroundBrush}"/>
      <Setter Property="Foreground" Value="{DynamicResource SelectionForegroundBrush}"/>
    </Trigger>
  </Style.Triggers>
</Style>

<!-- Ensure the popup list (dropdown) is dark -->
<SolidColorBrush x:Key="{x:Static SystemColors.WindowBrushKey}"     Color="#4A4A4A"/>
<SolidColorBrush x:Key="{x:Static SystemColors.WindowTextBrushKey}" Color="#FF000000"/>

    <!-- Default text color -->
    <Style TargetType="TextBlock">
        <Setter Property="Foreground" Value="{DynamicResource PrimaryForegroundBrush}"/>
    </Style>

    <!-- Button style -->
    <Style TargetType="Button">
        <Setter Property="Background" Value="{DynamicResource ContentBackgroundBrush}"/>
        <Setter Property="BorderBrush" Value="{DynamicResource BorderBrushColor}"/>
        <Setter Property="BorderThickness" Value="1"/>
        <Setter Property="Foreground" Value="{DynamicResource PrimaryForegroundBrush}"/>
        <Setter Property="Padding" Value="8,4"/>
        <Setter Property="Cursor" Value="Hand"/>
        <Setter Property="Template">
            <Setter.Value>
                <ControlTemplate TargetType="Button">
                    <Border x:Name="border" Background="{TemplateBinding Background}"
                            BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}"
                            CornerRadius="4">
                        <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"
                                          Margin="{TemplateBinding Padding}"
                                          Content="{TemplateBinding Content}"/>
                    </Border>
                    <ControlTemplate.Triggers>
                        <Trigger Property="IsMouseOver" Value="True">
                            <Setter TargetName="border" Property="Background" Value="#333"/>
                        </Trigger>
                        <Trigger Property="IsPressed" Value="True">
                            <Setter TargetName="border" Property="Background" Value="#444"/>
                        </Trigger>
                        <Trigger Property="IsEnabled" Value="False">
                            <Setter TargetName="border" Property="Opacity" Value="0.6"/>
                        </Trigger>
                    </ControlTemplate.Triggers>
                </ControlTemplate>
            </Setter.Value>
        </Setter>
    </Style>

    <!-- Info icon container -->
    <Style x:Key="InfoIconStyle" TargetType="Grid">
        <Setter Property="Width" Value="24"/>
        <Setter Property="Height" Value="24"/>
        <Setter Property="Margin" Value="0,0,10,10"/>
    </Style>

    <!-- Circular info icon -->
    <Style x:Key="InfoIconEllipseStyle" TargetType="Ellipse">
        <Setter Property="Width" Value="24"/>
        <Setter Property="Height" Value="24"/>
        <Setter Property="Fill" Value="#0078D7"/>
        <Setter Property="StrokeThickness" Value="0"/>
        <Style.Triggers>
            <Trigger Property="IsMouseOver" Value="True">
                <Setter Property="Fill" Value="#005A9E"/>
            </Trigger>
        </Style.Triggers>
    </Style>

    <Style x:Key="InfoIconTextStyle" TargetType="TextBlock">
        <Setter Property="Foreground" Value="{DynamicResource PopupForegroundBrush}"/>
        <Setter Property="FontWeight" Value="Bold"/>
        <Setter Property="FontSize" Value="14"/>
        <Setter Property="HorizontalAlignment" Value="Center"/>
        <Setter Property="VerticalAlignment" Value="Center"/>
        <Setter Property="IsHitTestVisible" Value="False"/>

          </Style>

    <!-- Priority ComboBox items -->
    <Style x:Key="PriorityItemStyle" TargetType="ComboBoxItem">
        <Style.Triggers>
            <Trigger Property="Content" Value="Low">
                <Setter Property="Foreground" Value="LightGreen"/>
            </Trigger>
            <Trigger Property="Content" Value="Medium">
                <Setter Property="Foreground" Value="Khaki"/>
            </Trigger>
            <Trigger Property="Content" Value="High">
                <Setter Property="Foreground" Value="Salmon"/>
            </Trigger>
        </Style.Triggers>
    </Style>

    <!-- Rounded text box style -->
    <Style x:Key="RoundedTextBox" TargetType="TextBox">
        <Setter Property="Background" Value="{DynamicResource ContentBackgroundBrush}"/>
        <Setter Property="BorderBrush" Value="{DynamicResource BorderBrushColor}"/>
        <Setter Property="BorderThickness" Value="1"/>
        <Setter Property="Foreground" Value="{DynamicResource PrimaryForegroundBrush}"/>
        <Setter Property="Padding" Value="4"/>
        <Setter Property="Template">
            <Setter.Value>
                <ControlTemplate TargetType="TextBox">
                    <Border Background="{TemplateBinding Background}"
                            BorderBrush="{TemplateBinding BorderBrush}"
                            BorderThickness="{TemplateBinding BorderThickness}"
                            CornerRadius="4">
                        <ScrollViewer x:Name="PART_ContentHost"/>
                    </Border>
                </ControlTemplate>
            </Setter.Value>
        </Setter>
    </Style>
</ResourceDictionary>
'@
Add-Type -TypeDefinition $signature


# ───────────────────────────────────────────────────────────────────
# EMBEDDED LogsWindow XAML
# ───────────────────────────────────────────────────────────────────
$LogsWindowXaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Application Logs"
        Height="600" Width="800"
        Background="{DynamicResource WindowBackgroundBrush}"
        FontFamily="Segoe UI"
        FontSize="13"
        WindowStartupLocation="CenterOwner">
  <Grid Margin="10">
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>   <!-- Controls -->
      <RowDefinition Height="*"/>      <!-- Log list -->
      <RowDefinition Height="Auto"/>   <!-- Close button -->
    </Grid.RowDefinitions>

    <!-- Top toolbar -->
    <StackPanel Orientation="Horizontal" Grid.Row="0" Margin="0,0,0,8">
      <Button x:Name="RefreshLogsButton"
              Content="Refresh"
              Style="{DynamicResource {x:Type Button}}"
              Padding="8,4"/>
      <ComboBox x:Name="LevelFilterComboBox"
                Margin="10,0,0,0"
                Width="150"
                Style="{DynamicResource {x:Type ComboBox}}"
                SelectedIndex="0">
        <ComboBoxItem>All Levels</ComboBoxItem>
        <ComboBoxItem>DEBUG</ComboBoxItem>
        <ComboBoxItem>INFO</ComboBoxItem>
        <ComboBoxItem>WARN</ComboBoxItem>
        <ComboBoxItem>ERROR</ComboBoxItem>
      </ComboBox>
    </StackPanel>

    <!-- Log entries list -->
    <Border Grid.Row="1"
            CornerRadius="4"
            BorderBrush="{DynamicResource BorderBrushColor}"
            BorderThickness="1"
            Padding="2"
            Background="{DynamicResource ContentBackgroundBrush}">
      <ListView x:Name="LogsListView"
                Margin="0"
                Background="{DynamicResource ContentBackgroundBrush}"
                Foreground="{DynamicResource PrimaryForegroundBrush}">
        <ListView.Resources>
          <!-- rows -->
          <Style TargetType="ListViewItem">
            <Setter Property="Background" Value="{DynamicResource ContentBackgroundBrush}"/>
            <Setter Property="Foreground" Value="{DynamicResource PrimaryForegroundBrush}"/>
          </Style>
          <!-- column headers -->
          <Style TargetType="GridViewColumnHeader">
            <Setter Property="Background" Value="{DynamicResource ContentBackgroundBrush}"/>
            <Setter Property="Foreground" Value="{DynamicResource PrimaryForegroundBrush}"/>
            <Setter Property="BorderBrush" Value="{DynamicResource BorderBrushColor}"/>
            <Setter Property="BorderThickness" Value="0,0,0,1"/>
          </Style>
        </ListView.Resources>
        <ListView.View>
          <GridView>
            <GridViewColumn Header="Timestamp" Width="180"
                            DisplayMemberBinding="{Binding Timestamp, StringFormat={}{0:yyyy-MM-dd HH:mm:ss}}"/>
            <GridViewColumn Header="Level" Width="80"
                            DisplayMemberBinding="{Binding Level}"/>
            <GridViewColumn Header="User" Width="140"
                DisplayMemberBinding="{Binding User}"/>
            <GridViewColumn Header="Message" Width="Auto">
              <GridViewColumn.CellTemplate>
                <DataTemplate>
                  <TextBlock Text="{Binding Message}"
                             TextWrapping="Wrap"/>
                </DataTemplate>
              </GridViewColumn.CellTemplate>
            </GridViewColumn>
          </GridView>
        </ListView.View>
      </ListView>
    </Border>

    <!-- Close button -->
    <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,8,0,0">
      <Button x:Name="CloseLogsButton"
              Content="Close"
              IsCancel="True"
              Style="{DynamicResource {x:Type Button}}"
              Padding="10,5"/>
    </StackPanel>
  </Grid>
</Window>
'@
# 2. Paths & Globals
$inv = $MyInvocation.MyCommand
if ($inv.Path) {
    # when running as .ps1 or compiled .exe, Path is the full filename
    $ScriptDir = Split-Path -Parent $inv.Path
}
else {
    # absolute fallback
    $ScriptDir = (Get-Location).ProviderPath
}

# 1a. Logging Setup
$LogsRoot = Join-Path $ScriptDir 'Logs'
if (-not (Test-Path $LogsRoot)) {
    New-Item -Path $LogsRoot -ItemType Directory | Out-Null
}
# Cleanup files older than 30 days
Get-ChildItem $LogsRoot -Filter '*.log' |
  Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } |
  Remove-Item -Force

function Write-Log {
    param(
        [ValidateSet('DEBUG','INFO','WARN','ERROR')] $Level,
        [string] $Message,
        [hashtable] $Context
    )
    $entry = @{
        Timestamp = (Get-Date).ToString('o')
        Level     = $Level
        User      = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
        Message   = $Message
        Context   = $Context
    }
    $json = $entry | ConvertTo-Json -Compress
    $path = Join-Path $LogsRoot "$(Get-Date -Format 'yyyy-MM-dd').log"
    [IO.File]::AppendAllText($path, $json + "`n")
}

Write-Log 'INFO' 'Logger initialized' @{ }

# 3. Load/Save Config for JSON Path
$configFile = Join-Path $ScriptDir "config.json"
$global:UseDarkTheme = $false
$configData = $null
if (Test-Path $configFile) {
    try {
        $configData     = Get-Content $configFile -Raw | ConvertFrom-Json
        $global:JSONFile = $configData.JSONFilePath
        if ($configData.PSObject.Properties['UseDarkTheme']) {
            $global:UseDarkTheme = [bool]$configData.UseDarkTheme
        }
    }
    catch {
        Write-Log 'WARN' 'Failed to parse config.json' @{ File = $configFile; Error = $_.Exception.Message }
        $global:JSONFile = $null
    }
}
if (-not $global:JSONFile) {
    Add-Type -AssemblyName System.Windows.Forms
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Title            = "Select JSON file for projects"
    $dlg.Filter           = "JSON Files (*.json)|*.json|All Files (*.*)|*.*"
    $dlg.InitialDirectory = [Environment]::GetFolderPath("MyDocuments")
    if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Write-Log 'INFO' 'JSON file selected' @{ File = $dlg.FileName }
        $global:JSONFile = $dlg.FileName
        @{ JSONFilePath = $global:JSONFile; UseDarkTheme = $global:UseDarkTheme } |
            ConvertTo-Json -Depth 2 |
            Set-Content $configFile
    }
    else {

        exit 1
    }
}
$DataFile = $global:JSONFile

# Attachments root folder
$attachmentsRoot = Join-Path (Split-Path $DataFile) 'Attachments'

# Mapping used to enforce a stable tile order
$statusOrder = @{
    'Not Started' = 0
    'Ongoing'     = 1  
    'Complete'    = 2
}

function Apply-StatusOrder {
    foreach ($p in $ProjectsCollection) {
        $order = if ($statusOrder.ContainsKey($p.Status)) { $statusOrder[$p.Status] } else { 3 }
        $p | Add-Member -NotePropertyName StatusOrder -NotePropertyValue $order -Force
    }
}

# 4. Load Existing Projects (cleaned up)

$ProjectsList = @()
$parsed = $null

if (Test-Path $DataFile) {
    try {
        $raw = Get-Content $DataFile -Raw

        # Try decrypting first
        try {
            $decrypted = Decrypt-WithAES $raw
            $parsed = $decrypted | ConvertFrom-Json
            Write-Log 'INFO' 'Loaded encrypted project file.' @{ }
        }
        catch {
            Write-Log 'INFO' 'Decryption failed, attempting plaintext parse.' @{ }

            try {
                # Try plaintext
                $parsed = $raw | ConvertFrom-Json

                # Re-encrypt
                $json = $parsed | ConvertTo-Json -Depth 5 -Compress
                $encrypted = Encrypt-WithAES $json
                Set-Content -Path $DataFile -Value $encrypted -Force

                Write-Log 'INFO' 'Migrated plaintext to encrypted JSON.' @{ }
            }
            catch {
                Write-Log 'ERROR' 'Failed to parse or encrypt plaintext JSON' @{ Error = $_.Exception.Message }
            }
        }

        # Extract projects
        if ($parsed -is [System.Array]) {
            $ProjectsList = $parsed
        }
        elseif ($parsed.PSObject.Properties['projects']) {
            $ProjectsList = $parsed.projects
        }
    }
    catch {
        Write-Log 'ERROR' 'Failed to load JSON file' @{ Error = $_.Exception.Message }
    }
}

# Normalize project structure
foreach ($p in $ProjectsList) {
    if ($p.PSObject.Properties['CreationDate']) {
        $cd = $p.CreationDate
        if ($cd -is [string]) {
            $p.CreationDate = [DateTime]$cd
        }
        elseif ($cd -is [PSCustomObject] -and $cd.value) {
            $p.CreationDate = [DateTime]$cd.value
        }
    }
    if (-not $p.PSObject.Properties['Subject']) {
        $p | Add-Member -NotePropertyName Subject -NotePropertyValue '' -Force
    }
    if (-not $p.PSObject.Properties['Attachments']) {
        $p | Add-Member -NotePropertyName Attachments -NotePropertyValue @() -Force
    }
}



$ProjectsCollection = [System.Collections.ObjectModel.ObservableCollection[Object]]::new()
$ProjectsList | ForEach-Object { $ProjectsCollection.Add($_) }

Apply-StatusOrder

# Assign stable GUIDs if missing
$needsSave = $false
foreach ($p in $ProjectsCollection) {
    if (-not $p.PSObject.Properties['Id']) {
        $p | Add-Member -NotePropertyName Id -NotePropertyValue ([guid]::NewGuid().ToString())
        $needsSave = $true
    }
     if (-not $p.PSObject.Properties['Subject']) {
        $p | Add-Member -NotePropertyName Subject -NotePropertyValue '' -Force
        $needsSave = $true
    }
    if (-not $p.PSObject.Properties['Attachments']) {
        $p | Add-Member -NotePropertyName Attachments -NotePropertyValue @() -Force
        $needsSave = $true
    }
    if (-not $p.PSObject.Properties['Priority']) {
        $p | Add-Member -NotePropertyName Priority -NotePropertyValue 'Low' -Force
        $needsSave = $true
    }
}
if ($needsSave) {
    $m = New-Object System.Threading.Mutex($false, $mutexName)
    if ($m.WaitOne(5000)) {
        try {
            @{ projects = $ProjectsCollection } |
                ConvertTo-Json -Depth 5 -Compress |
                Set-Content -Path $DataFile -Force
            Write-Log 'INFO' 'Assigned missing IDs and saved initial project list' @{ }
        }
        finally {
            $m.ReleaseMutex(); $m.Dispose()
        }
    }
}

# 5. Sync Functions
function Save-ProjectToJson {
    param($project)
    Write-Log 'DEBUG' 'Entered Save-ProjectToJson' @{ Id = $project.Id }

    if ([string]::IsNullOrWhiteSpace($project.Name)) {
        Write-Log 'INFO' 'Project removed due to missing title' @{ Id = $project.Id }
        if ($project.PSObject.Properties['Id']) {
            Remove-ProjectFromJson $project
        }
        return
    }

    if (-not $project.PSObject.Properties['Subject']) {
        $project | Add-Member -NotePropertyName Subject -NotePropertyValue '' -Force
    }
    if (-not $project.PSObject.Properties['Priority']) {
        $project | Add-Member -NotePropertyName Priority -NotePropertyValue 'Low' -Force
    }

    $m = New-Object System.Threading.Mutex($false, $mutexName)
    try {
        if (-not $m.WaitOne(5000)) {
          
            return
        }

        $raw  = Get-Content $DataFile -Raw
        $disk = $raw | ConvertFrom-Json

        # Normalize container
        $isArray = $false
        if ($disk -is [System.Array]) {
            $container = [PSCustomObject]@{ projects = $disk }; $isArray = $true
        }
        elseif ($disk.PSObject.Properties['projects']) {
            $container = $disk
        }
        else {
            $container = [PSCustomObject]@{ projects = @() }
        }

        $arr = if ($isArray) { $disk }
               elseif ($container.projects -is [System.Array]) { $container.projects }
               else { @($container.projects) }

        # Ensure Id & Number
        if (-not $project.PSObject.Properties['Id']) {
            $project | Add-Member -NotePropertyName Id -NotePropertyValue ([guid]::NewGuid().ToString()) -Force
        }
        if (-not $project.PSObject.Properties['Number']) {
            $next = Get-NextTicketNumber
            $project | Add-Member -NotePropertyName Number -NotePropertyValue $next -Force
        }

        # Update or add
        $existing = $arr | Where-Object Id -eq $project.Id
        if ($existing) {
            if (-not $existing.PSObject.Properties['Number']) {
                $existing | Add-Member -NotePropertyName Number -NotePropertyValue $project.Number -Force
            }
            $existing.Name        = $project.Name
            $existing.Status      = $project.Status
            $existing | Add-Member -NotePropertyName Priority -NotePropertyValue $project.Priority -Force
            $existing.WorkLog     = $project.WorkLog
            if (-not $existing.PSObject.Properties['Attachments']) {
                $existing | Add-Member -NotePropertyName Attachments -NotePropertyValue @() -Force
            }
            $existing.Attachments = $project.Attachments
        }
        else {
            $arr += [PSCustomObject]@{
                Id           = $project.Id
                Number       = $project.Number
                Name         = $project.Name
                Status       = $project.Status
                Priority     = $project.Priority
                WorkLog      = $project.WorkLog
                Attachments  = $project.Attachments
                CreationDate = $project.CreationDate
            }
        }

        # Write back
        if ($isArray) {
            $plainJson = $arr | ConvertTo-Json -Depth 5 -Compress
$encrypted = Encrypt-WithAES $plainJson
Set-Content -Path $DataFile -Value $encrypted -Force

        }
        else {
            $container.projects = $arr
            $json      = $container | ConvertTo-Json -Depth 5 -Compress
$encrypted = Encrypt-WithAES $json
Set-Content -Path $DataFile -Value $encrypted -Force

        }

        Write-Log 'INFO' 'Project saved' @{ Id = $project.Id; Number = $project.Number }
    }
    catch {
        Write-Log 'ERROR' 'Exception in Save-ProjectToJson' @{ Error = $_.Exception.Message }
        throw
    }
    finally {
        $m.ReleaseMutex(); $m.Dispose()
    }
}

function Get-NextTicketNumber {
 

    $m = New-Object System.Threading.Mutex($false, $mutexName)
    try {
        if (-not $m.WaitOne(5000)) {
            
            return 1
        }
        if (-not (Test-Path $DataFile)) { return 1 }

        $raw   = Get-Content -Path $DataFile -Raw
        $disk  = $raw | ConvertFrom-Json
        $projects = if ($disk -is [System.Array]) { $disk }
                    elseif ($disk.PSObject.Properties['projects']) { $disk.projects }
                    else { @() }

        $max = ($projects | Where-Object { $_.PSObject.Properties['Number'] } |
                Measure-Object -Property Number -Maximum).Maximum
        if (-not $max) { $max = 0 }
        $next = [int]$max + 1

      
        return $next
    }
    catch {
        Write-Log 'ERROR' 'Failed in Get-NextTicketNumber' @{ Error = $_.Exception.Message }
        return 1
    }
    finally {
        $m.ReleaseMutex(); $m.Dispose()
    }
}
function Show-LogsWindow {
    # Load LogsWindow.xaml
    [xml]$lxaml = $LogsWindowXaml
    $lxaml.Window.RemoveAttribute('x:Class')
    $logWin = [System.Windows.Markup.XamlReader]::Load(
        (New-Object System.Xml.XmlNodeReader $lxaml)
    )

    # Apply current theme resources so brushes like WindowBackgroundBrush resolve
    $logWin.Resources.MergedDictionaries.Clear()
    $xml = if ($global:UseDarkTheme) { $darkStyles } else { $lightStyles }
    $dict = [System.Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xml))
    $logWin.Resources.MergedDictionaries.Add($dict)

    # Find its controls
    $refreshBtn = $logWin.FindName("RefreshLogsButton")
    $levelFilter = $logWin.FindName("LevelFilterComboBox")
    $listView = $logWin.FindName("LogsListView")
    $closeBtn = $logWin.FindName("CloseLogsButton")

    # Function to (re)load logs from your Logs folder
    $reloadLogs = {
        # Grab all .log files from $LogsRoot and parse as JSON lines
        $entries = Get-ChildItem $LogsRoot -Filter '*.log' |
                   Sort-Object LastWriteTime -Descending |
                   ForEach-Object {
                       Get-Content $_.FullName | ForEach-Object {
                           try { ConvertFrom-Json $_ } catch { $null }
                       }
                   } | Where-Object { $_ }

        # Apply level filter
        $sel = $levelFilter.SelectedItem.Content
        if ($sel -and $sel -ne 'All Levels') {
            $entries = $entries | Where-Object Level -eq $sel
        }

        # Bind into ListView
        $listView.ItemsSource = $entries
    }

    # Wire buttons
    $refreshBtn.Add_Click({ & $reloadLogs })
    $levelFilter.Add_SelectionChanged({ & $reloadLogs })
    $closeBtn.Add_Click({ $logWin.Close() })

    # Center and show
    $logWin.Owner = $MainWindow
    # Pre-load once
    & $reloadLogs
    $logWin.ShowDialog() | Out-Null
}

function Remove-ProjectFromJson {
    param($project)
    Write-Log 'DEBUG' 'Entered Remove-ProjectFromJson' @{ Id = $project.Id }

    $m = New-Object System.Threading.Mutex($false, $mutexName)
    try {
        if (-not $m.WaitOne(5000)) {
            Write-Log 'WARN' 'Timeout acquiring delete mutex' @{ Mutex = $mutexName }
            return
        }
        $raw   = Get-Content $DataFile -Raw
        $disk  = $raw | ConvertFrom-Json
        $isArray = $disk -is [System.Array]
        $container = if ($isArray) { [PSCustomObject]@{ projects = $disk } } else { $disk }
        $arr = $container.projects | Where-Object Id -ne $project.Id

        if ($isArray) {
            $arr | ConvertTo-Json -Depth 5 -Compress | Set-Content $DataFile -Force
        }
        else {
            $container.projects = $arr
            $container | ConvertTo-Json -Depth 5 -Compress | Set-Content $DataFile -Force
        }

        Write-Log 'INFO' 'Project removed' @{ Id = $project.Id }
    }
    catch {
        Write-Log 'ERROR' 'Exception in Remove-ProjectFromJson' @{ Error = $_.Exception.Message }
        throw
    }
    finally {
        $m.ReleaseMutex(); $m.Dispose()
    }
}

function Sync-ProjectsFromJson {
    

    $m = New-Object System.Threading.Mutex($false, $mutexName)
    try {
        if (-not $m.WaitOne(5000)) {
            Write-Log 'WARN' 'Timeout acquiring reload mutex' @{ Mutex = $mutexName }
            return
        }
        $raw    = Get-Content $DataFile -Raw
        $parsed = $raw | ConvertFrom-Json
        $plist  = if ($parsed -is [System.Array]) { $parsed }
                 elseif ($parsed.PSObject.Properties['projects']) { $parsed.projects }
                 else { @() }

        
        $ProjectsCollection.Clear()
        $plist | ForEach-Object {
            if (-not $_.PSObject.Properties['Priority']) {
                $_ | Add-Member -NotePropertyName Priority -NotePropertyValue 'Low' -Force
            }
            $ProjectsCollection.Add($_)
        }
        Apply-StatusOrder
    }
    catch {
        Write-Log 'ERROR' 'Exception in Sync-ProjectsFromJson' @{ Error = $_.Exception.Message }
        throw
    }
    finally {
        $m.ReleaseMutex(); $m.Dispose()
    }
}

# ──────────────────────────────────────────────────
# 6. Load XAML & Styles from embedded here-strings
# ──────────────────────────────────────────────────

# Parse our embedded strings
[xml]$mainXaml    = $MainWindowXaml
[xml]$lightStyles = $StylesXaml
[xml]$darkStyles  = $DarkStylesXaml

# Strip code-behind attributes
$mainXaml.Window.RemoveAttribute('x:Class')
$mainXaml.Window.RemoveAttribute('mc:Ignorable')

# Instantiate the window

$MainWindow = [System.Windows.Markup.XamlReader]::Load(
  (New-Object System.Xml.XmlNodeReader $mainXaml)
)

if (-not $MainWindow) {
    Write-Error "Failed to create main window from XAML."
    exit 1
}

# Then wire up your converter & theme logic exactly as before:
Add-Type -ReferencedAssemblies PresentationFramework, Microsoft.CSharp -TypeDefinition @"
using System;
using System.Windows.Data;
using System.Globalization;
public class PSCustomDateConverter : IValueConverter {
  public object Convert(object value, Type targetType, object parameter, CultureInfo culture) {
    dynamic obj = value;
    string s = obj != null ? obj.value as string : null;
    DateTime dt;
    if (s != null && DateTime.TryParse(s, out dt)) return dt;
    return value;
  }
  public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture) {
    throw new NotImplementedException();
  }
}
"@

$converter = [PSCustomDateConverter]::new()
if (-not $MainWindow.Resources.Contains('DateConv')) {
  $MainWindow.Resources.Add('DateConv', $converter)
}
else {
  $MainWindow.Resources['DateConv'] = $converter
}

function Set-Theme([bool]$dark) {
    $MainWindow.Resources.MergedDictionaries.Clear()
    $xml = if ($dark) { $darkStyles } else { $lightStyles }
    $dict = [System.Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xml))
    $MainWindow.Resources.MergedDictionaries.Add($dict)
    $global:UseDarkTheme = $dark
  }
  Set-Theme $global:UseDarkTheme

# 7. Wire Up UI Controls & Handlers
$SearchBox                = $MainWindow.FindName("SearchBox")
$DateRangeFilter          = $MainWindow.FindName("DateRangeFilter")
$RefreshButton            = $MainWindow.FindName("RefreshButton")
$ProjectList              = $MainWindow.FindName("ProjectList")
$AddProjectButton         = $MainWindow.FindName("AddProjectButton")
$ChangeDataFileMenuItem   = $MainWindow.FindName("ChangeDataFileMenuItem")
  $DarkModeMenuItem         = $MainWindow.FindName("DarkModeMenuItem")
  $DarkModeMenuItem.IsChecked = $global:UseDarkTheme
  $StatusFilterMenuItem     = $MainWindow.FindName("StatusFilterMenuItem")
$FilterAllMenuItem        = $MainWindow.FindName("FilterAllMenuItem")
$FilterNotStartedMenuItem = $MainWindow.FindName("FilterNotStartedMenuItem")
$FilterOngoingMenuItem    = $MainWindow.FindName("FilterOngoingMenuItem")
$FilterCompleteMenuItem   = $MainWindow.FindName("FilterCompleteMenuItem")
$ViewLogsMenuItem         = $MainWindow.FindName("ViewLogsMenuItem")

$global:StatusFilter = 'All'

$view = [System.Windows.Data.CollectionViewSource]::GetDefaultView($ProjectsCollection)
$view.GroupDescriptions.Add((New-Object System.Windows.Data.PropertyGroupDescription("Status")))
$ProjectList.ItemsSource = $ProjectsCollection

Apply-StatusOrder

# Ensure the view respects the custom status order
$view.SortDescriptions.Clear()
$view.SortDescriptions.Add([ComponentModel.SortDescription]::new('StatusOrder',[ComponentModel.ListSortDirection]::Ascending))

$view.Filter = {
    param($p)
    $t            = $SearchBox.Text.ToLower().Trim()
    $nameMatch    = [string]::IsNullOrEmpty($t) -or $p.Name.ToLower().Contains($t)
    $numberMatch  = [string]::IsNullOrEmpty($t) -or ($p.PSObject.Properties['Number'] -and $p.Number.ToString().ToLower().Contains($t))
    $subjectMatch = [string]::IsNullOrEmpty($t) -or ($p.PSObject.Properties['Subject'] -and $p.Subject.ToLower().Contains($t))
    $range        = $DateRangeFilter.SelectedItem.Content
    $start        = $null
    switch ($range) {
        'Last 30 Days'  { $start = (Get-Date).AddDays(-30) }
        'Last 6 Months' { $start = (Get-Date).AddMonths(-6) }
        'Last Year'     { $start = (Get-Date).AddYears(-1) }
    }
    $textMatch = $nameMatch -or $numberMatch -or $subjectMatch
    $statusOk  = $global:StatusFilter -eq 'All' -or $p.Status -eq $global:StatusFilter
    $cd = if ($p.CreationDate -is [pscustomobject]) { [datetime]$p.CreationDate.value } else { [datetime]$p.CreationDate }
if ($start) { $textMatch -and $statusOk -and ($cd -ge $start) }
else        { $textMatch -and $statusOk }

}

$SearchBox.Add_TextChanged({
    $view.Refresh()
})
$DateRangeFilter.Add_SelectionChanged({
    $view.Refresh()
})
$RefreshButton.Add_Click({
    Sync-ProjectsFromJson; $view.Refresh()
})

$FilterAllMenuItem.Add_Click({
    $global:StatusFilter = 'All'; $StatusFilterMenuItem.Header = 'Status: All'
    $view.Refresh()
})
$FilterNotStartedMenuItem.Add_Click({
    $global:StatusFilter = 'Not Started'; $StatusFilterMenuItem.Header = 'Status: Not Started'
    $view.Refresh()
})
$FilterOngoingMenuItem.Add_Click({
    $global:StatusFilter = 'Ongoing'; $StatusFilterMenuItem.Header = 'Status: Ongoing'
    $view.Refresh()
})
$FilterCompleteMenuItem.Add_Click({
    $global:StatusFilter = 'Complete'; $StatusFilterMenuItem.Header = 'Status: Complete'
    $view.Refresh()
})

$ChangeDataFileMenuItem.Add_Click({
    Add-Type -AssemblyName System.Windows.Forms
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Title            = "Select JSON file for projects"
    $dlg.Filter           = "JSON Files (*.json)|*.json|All Files (*.*)|*.*"
    $dlg.InitialDirectory = [System.IO.Path]::GetDirectoryName($global:JSONFile)
    if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $global:JSONFile = $dlg.FileName; $script:DataFile = $global:JSONFile
        @{ JSONFilePath = $global:JSONFile; UseDarkTheme = $global:UseDarkTheme } | ConvertTo-Json -Depth 2 | Set-Content $configFile
        Write-Log 'INFO' 'Data file changed' @{ File = $global:JSONFile }
        Sync-ProjectsFromJson; $view.Refresh()
    }
})

$DarkModeMenuItem.Add_Checked({
      Set-Theme $true
      @{ JSONFilePath = $global:JSONFile; UseDarkTheme = $global:UseDarkTheme } | ConvertTo-Json -Depth 2 | Set-Content $configFile
  })
  $DarkModeMenuItem.Add_Unchecked({
      Set-Theme $false
      @{ JSONFilePath = $global:JSONFile; UseDarkTheme = $global:UseDarkTheme } | ConvertTo-Json -Depth 2 | Set-Content $configFile
  })
$ViewLogsMenuItem.Add_Click({
    Show-LogsWindow
})
# 8. Auto-Reload Timer
$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromSeconds(3)
$timer.Add_Tick({
    Sync-ProjectsFromJson
    $view.Refresh()
})
$timer.Start()


# 9. Main Event Handlers
$ProjectList.Add_MouseDoubleClick({
    if (-not $global:DetailWindowOpen -and $ProjectList.SelectedItem) {
       
        $global:DetailWindowOpen = $true; $timer.Stop()
        Show-ProjectDetailWindow $ProjectList.SelectedItem
        Sync-ProjectsFromJson; $view.Refresh()
        $timer.Start(); $global:DetailWindowOpen = $false
    }
})

$AddProjectButton.Add_Click({
    if (-not $global:DetailWindowOpen) {
        $global:DetailWindowOpen = $true; $timer.Stop()
        $new = [PSCustomObject]@{
            Name         = ""; Status = "Not Started"; Subject = ""; Priority = "Low";
            WorkLog      = @(); Attachments = @(); CreationDate = Get-Date
        }
        if (Show-ProjectDetailWindow $new) { Save-ProjectToJson $new }
        Sync-ProjectsFromJson; $view.Refresh()
        $timer.Start(); $global:DetailWindowOpen = $false
    }
})

# 10. Modal Editor for Log Entries
function Show-EntryEditWindow {
    param($entry)
    $xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Edit Log Entry" Width="500" Height="300"
        WindowStartupLocation="CenterOwner"
        ResizeMode="CanResizeWithGrip"
        MinWidth="400" MinHeight="200">
  <Grid Margin="10">
    <Grid.RowDefinitions>
      <RowDefinition Height="*"/><RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/><RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>
    <Grid.ColumnDefinitions>
      <ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/>
    </Grid.ColumnDefinitions>
    <TextBlock Text="Description:" Grid.Row="0" Grid.Column="0" Margin="0,0,5,5"/>
    <TextBox x:Name="EditDescription" Grid.Row="0" Grid.Column="1" TextWrapping="Wrap" AcceptsReturn="True" VerticalScrollBarVisibility="Auto" Margin="0,0,0,5"/>
    <TextBlock Text="Subject:"     Grid.Row="1" Grid.Column="0" Margin="0,0,5,5"/>
    <TextBox x:Name="EditSubject"  Grid.Row="1" Grid.Column="1" Margin="0,0,0,5"/>
    <TextBlock Text="Rank / Name:"    Grid.Row="2" Grid.Column="0" Margin="0,0,5,5"/>
    <TextBox x:Name="EditDuration" Grid.Row="2" Grid.Column="1" Width="100" Margin="0,0,0,5"/>
    <StackPanel Grid.Row="3" Grid.ColumnSpan="2" Orientation="Horizontal" HorizontalAlignment="Right">
      <Button x:Name="OKButton"     Content="OK"     Width="75" Margin="0,0,10,0"/>
      <Button x:Name="CancelButton" Content="Cancel" Width="75"/>
    </StackPanel>
  </Grid>
</Window>
"@
    [xml]$doc   = $xaml
    $window     = [System.Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $doc))
    $descBox    = $window.FindName("EditDescription")
    $subjectBox = $window.FindName("EditSubject")
    $durBox     = $window.FindName("EditDuration")
    $okBtn      = $window.FindName("OKButton")
    $cancelBtn  = $window.FindName("CancelButton")

    $descBox.Text    = $entry.Description
    $subjectBox.Text = $entry.Subject
    $durBox.Text     = $entry.Duration

    $okBtn.Add_Click({
        $entry.Description = $descBox.Text
        $entry.Subject     = $subjectBox.Text
        $entry.Duration    = $durBox.Text
        $window.DialogResult = $true
    })
    $cancelBtn.Add_Click({ $window.DialogResult = $false })

    $window.Owner = $MainWindow
    return ($window.ShowDialog() -eq $true)
}

# 11. Project Detail Window Function
function Show-ProjectDetailWindow {
    param([Object]$project)

    # ─── Ensure required properties exist ───
    if (-not $project.PSObject.Properties['Id']) {
        $project | Add-Member -NotePropertyName Id -NotePropertyValue ([guid]::NewGuid().ToString()) -Force
    }
    if (-not $project.PSObject.Properties['Subject']) {
        $project | Add-Member -NotePropertyName Subject -NotePropertyValue '' -Force
    }
    if (-not $project.PSObject.Properties['Attachments']) {
        $project | Add-Member -NotePropertyName Attachments -NotePropertyValue @() -Force
    }
    if (-not $project.PSObject.Properties['WorkLog']) {
        $project | Add-Member -NotePropertyName WorkLog -NotePropertyValue @() -Force
    }
    if (-not $project.PSObject.Properties['Priority']) {
        $project | Add-Member -NotePropertyName Priority -NotePropertyValue 'Low' -Force
    }
    # ────────────────────────────────────────────

    # Load the raw XAML for the detail window
    $dx = [xml]$ProjectDetailWindowXaml
    $dx.Window.RemoveAttribute('x:Class')
    $dx.Window.RemoveAttribute('mc:Ignorable')

    # Merge styles
    $stylesXml = if ($global:UseDarkTheme) { $darkStyles } else { $lightStyles }
    $ns        = $dx.DocumentElement.NamespaceURI
    $winElem   = $dx.DocumentElement
    $resElem   = $dx.CreateElement("Window.Resources", $ns)
    $rdElem    = $dx.CreateElement("ResourceDictionary", $ns)
    foreach ($node in $stylesXml.ResourceDictionary.ChildNodes) {
        if ($node.NodeType -eq 'Element') {
            $imported = $dx.ImportNode($node, $true)
            $rdElem.AppendChild($imported) | Out-Null
        }
    }
    $resElem.AppendChild($rdElem) | Out-Null
    $firstChild = $winElem.ChildNodes | Where-Object { $_.NodeType -eq 'Element' } | Select-Object -First 1
    $winElem.InsertBefore($resElem, $firstChild) | Out-Null

    # Load detail window
    $win = [System.Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $dx))

    # Find controls
    $NumberBlock   = $win.FindName("NumberTextBlock")
    $NameBox       = $win.FindName("NameTextBox")
    $StatusBox     = $win.FindName("StatusComboBox")
    $SubjectBox    = $win.FindName("SubjectTextBox")
    $PriorityBox   = $win.FindName("PriorityComboBox")
    $AddAttBtn     = $win.FindName("AddAttachmentButton")
    $RemoveAttBtn  = $win.FindName("RemoveAttachmentButton")
    $AttList       = $win.FindName("AttachmentListBox")
    $DescBox       = $win.FindName("DescriptionTextBox")
    $DurBox        = $win.FindName("DurationTextBox")
    $AddBtn        = $win.FindName("AddEntryButton")
    $LogListView   = $win.FindName("LogListView")
    $RemoveBtn     = $win.FindName("RemoveEntryButton")
    $SaveBtn       = $win.FindName("SaveButton")
    $CancelBtn     = $win.FindName("CancelButton")
    $DeleteProjBtn = $win.FindName("DeleteProjectButton")
    $TransferBtn   = $win.FindName("TransferTicketButton")

    # Populate fields
    if ($project.PSObject.Properties['Number']) {
        $NumberBlock.Text = $project.Number
    }
    else {
        $NumberBlock.Text = "(new ticket)"
    }
    $NameBox.Text    = $project.Name
    $StatusBox.Items.Clear()
    "Not Started","Ongoing","Complete" | ForEach-Object { $StatusBox.Items.Add($_) }
    $StatusBox.SelectedItem = $project.Status
    $SubjectBox.Text        = $project.Subject
    $PriorityBox.Items.Clear()
    "Low","Medium","High" | ForEach-Object { $PriorityBox.Items.Add($_) }
    $PriorityBox.SelectedItem = $project.Priority

    $AttList.Items.Clear()
    foreach ($a in $project.Attachments) {
        $AttList.Items.Add($a) | Out-Null
    }
    $LogListView.Items.Clear()
    foreach ($e in $project.WorkLog) {
        $LogListView.Items.Add([PSCustomObject]@{
            Timestamp   = [DateTime]$e.Timestamp
            Subject     = $e.Subject
            Description = $e.Description
            Duration    = $e.Duration
        })
    }

    # Entry editing
    $LogListView.Add_MouseDoubleClick({
        $sel = $LogListView.SelectedItem
        if ($sel -and (Show-EntryEditWindow $sel)) {
            $LogListView.Items.Refresh()
        }
    })
    $AddBtn.Add_Click({
        if ($DescBox.Text) {
            $LogListView.Items.Add([PSCustomObject]@{
                Timestamp   = Get-Date
                Subject     = $SubjectBox.Text
                Description = $DescBox.Text
                Duration    = $DurBox.Text
            })
            $DescBox.Clear(); $DurBox.Clear()
        }
    })
    $RemoveBtn.Add_Click({
        if ($LogListView.SelectedItem) {
            $LogListView.Items.Remove($LogListView.SelectedItem)
        }
        else {
            [System.Windows.MessageBox]::Show(
                "Please select an entry.",
                "No Entry Selected",
                [System.Windows.MessageBoxButton]::OK,
                [System.Windows.MessageBoxImage]::Information
            )
        }
    })

    # Attachment operations
    $AddAttBtn.Add_Click({
        Add-Type -AssemblyName System.Windows.Forms
        $dlg = New-Object System.Windows.Forms.OpenFileDialog
        $dlg.Multiselect = $true
        if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $ticketDir = Join-Path $attachmentsRoot $project.Id
            if (-not (Test-Path $ticketDir)) {
                New-Item -Path $ticketDir -ItemType Directory | Out-Null
            }
            foreach ($f in $dlg.FileNames) {
                $leaf = [IO.Path]::GetFileName($f)
                $dest = Join-Path $ticketDir $leaf
                Copy-Item $f $dest -Force
                $rel = Join-Path 'Attachments' (Join-Path $project.Id $leaf)
                if ($project.Attachments -notcontains $rel) {
                    $project.Attachments += $rel
                    $AttList.Items.Add($rel) | Out-Null
                }
            }
            Save-ProjectToJson $project
        }
    })
    $RemoveAttBtn.Add_Click({
        if ($AttList.SelectedItem) {
            $rel  = $AttList.SelectedItem
            $full = Join-Path (Split-Path $DataFile) $rel
            if (Test-Path $full) { Remove-Item $full -Force }
            $AttList.Items.Remove($rel)
            $project.Attachments = $project.Attachments | Where-Object { $_ -ne $rel }
            Save-ProjectToJson $project
        }
        else {
            [System.Windows.MessageBox]::Show(
                'Please select a file.',
                'No Attachment Selected',
                [System.Windows.MessageBoxButton]::OK,
                [System.Windows.MessageBoxImage]::Information
            )
        }
    })
    $AttList.Add_MouseDoubleClick({
        $sel = $AttList.SelectedItem
        if ($sel) {
            $full = Join-Path (Split-Path $DataFile) $sel
            Start-Process $full
        }
    })

    # Delete project
    $DeleteProjBtn.Add_Click({
        if (
            [System.Windows.MessageBox]::Show(
                "Delete this project?",
                "Confirm Delete",
                [System.Windows.MessageBoxButton]::YesNo,
                [System.Windows.MessageBoxImage]::Warning
            ) -eq 'Yes'
        ) {
            Write-Log 'INFO' 'Project deletion confirmed' @{ Id = $project.Id }
            $ProjectsCollection.Remove($project)
            Remove-ProjectFromJson $project
            $win.DialogResult = $true
            $win.Close()
        }
    })

    # Transfer project
    $TransferBtn.Add_Click({
        Add-Type -AssemblyName System.Windows.Forms
        $dlg = New-Object System.Windows.Forms.OpenFileDialog
        $dlg.Filter = 'JSON Files (*.json)|*.json|All Files (*.*)|*.*'
        if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $destFile = $dlg.FileName
            $origFile = $DataFile
            $m = New-Object System.Threading.Mutex($false, $mutexName)
            try {
                if (-not $m.WaitOne(5000)) {
                    Write-Log 'WARN' 'Timeout acquiring transfer mutex' @{ Mutex = $mutexName }
                    return
                }
                $DataFile = $destFile
                Save-ProjectToJson $project
                $DataFile = $origFile
                Remove-ProjectFromJson $project
                $ProjectsCollection.Remove($project)
                Sync-ProjectsFromJson
                foreach ($rel in $project.Attachments) {
                    $src = Join-Path (Split-Path $origFile) $rel
                    $dst = Join-Path (Split-Path $destFile) $rel
                    $dstDir = Split-Path $dst
                    if (-not (Test-Path $dstDir)) { New-Item -Path $dstDir -ItemType Directory | Out-Null }
                    if (Test-Path $src) { Move-Item -Path $src -Destination $dst -Force }
                }
                Write-Log 'INFO' 'Project transferred' @{ Id = $project.Id; Destination = $destFile }
                $win.DialogResult = $true
                $win.Close()
            }
            catch {
                Write-Log 'ERROR' 'Failed to transfer project' @{ Id = $project.Id; Error = $_.Exception.Message }
            }
            finally {
                $DataFile = $origFile
                $m.ReleaseMutex(); $m.Dispose()
            }
        }
    })

    # Save & Cancel
    $SaveBtn.Add_Click({
        $project.Name     = $NameBox.Text
        $project.Status   = $StatusBox.Text
        $project.Priority = $PriorityBox.Text
        $project.Subject  = $SubjectBox.Text
        $project.WorkLog = @()
        foreach ($item in $LogListView.Items) {
            $project.WorkLog += [PSCustomObject]@{
                Timestamp   = [DateTime]$item.Timestamp
                Subject     = $item.Subject
                Description = $item.Description
                Duration    = $item.Duration
            }
        }
        $project.Attachments = @()
        foreach ($i in $AttList.Items) { $project.Attachments += $i }
        Save-ProjectToJson $project
        $win.DialogResult = $true
        $win.Close()
    })
    $CancelBtn.Add_Click({ $win.DialogResult = $false })

    $win.Owner = $MainWindow
    return ($win.ShowDialog() -eq $true)
}

# 12. Show Main Window
if ($MainWindow) {
    $null = $MainWindow.ShowDialog()
} else {
    Write-Error "Main window was not initialized."
    exit 1
}
